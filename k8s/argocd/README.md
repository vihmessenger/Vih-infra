# Argo CD — GitOps for ViH Messenger

Infrastructure installs **Argo CD** on EKS via Terraform (`infrastructure-modules/argocd-bootstrap`).  
**AWS Load Balancer Controller** is managed as **`infra-live/prod/application/eks-lbc`** (Helm); public DNS for the Argo UI is optional **`infra-live/prod/post/route53-argocd`** — see those folders’ `README.md` for imports if you installed LBC/DNS manually.  
**Deployments** are driven by **Argo CD Applications** that watch the Git repo where **`k8s/charts/*`** lives.

**GitHub organization:** [vihmessenger](https://github.com/vihmessenger) — saari related repos is org ke under.

**Application code repos (CodePipeline → Docker → ECR):**

| Service | GitHub |
|---------|--------|
| CPaaS PHP | [vihmessenger/vih_cpass_php](https://github.com/vihmessenger/vih_cpass_php) |
| NLP (Django) | [vihmessenger/vih_nlp](https://github.com/vihmessenger/vih_nlp) — CodePipeline default branch **`main`** (`VIH_GITHUB_BRANCH_NLP`) |
| Web frontend | [vihmessenger/vih-messenger](https://github.com/vihmessenger/vih-messenger) — default **`main`** (`VIH_GITHUB_BRANCH_MESSENGER`) |

Set `repoURL` in `applications/*.yaml` to **[vihmessenger/Vih-infra](https://github.com/vihmessenger/Vih-infra)** (default: **`https://github.com/vihmessenger/Vih-infra.git`**).

## Flow (matches `ARCHITECTURE.md`)

1. **CI (CodePipeline)** builds Docker images and **pushes to ECR** only (no Helm deploy in pipeline when using GitOps).
2. **Git** remains the source of truth for Kubernetes: update image tags / Helm values in Git (or use **Argo CD Image Updater** later).
3. **Argo CD** syncs `k8s/charts/*` (or `applications/*.yaml`) to the cluster — **Enterprise / CPaaS / NLP** workloads roll out from Git, not from CodeBuild.

## Register the repo in Argo CD

After the UI is available (LoadBalancer URL or `kubectl port-forward`):

- Add your **Git repository** (HTTPS + token / SSH) under **Settings → Repositories**.
- Or create a **Secret** of type `repository` (see [Argo CD docs](https://argo-cd.readthedocs.io/)).

## Apply Applications

Templates live in `applications/`. Set `repoURL` and `targetRevision` to your real Git remote.

```bash
kubectl apply -f k8s/argocd/applications/
```

Or let a root **App of Apps** point at this folder.

## First-time admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## Argo CD UI on your domain (production)

Default hostname: **`argocd.platform.vihresearchlabs.ai`** (same ACM cert as `api.platform` / `ws.platform` / `app.platform` — see `infra-live/prod/pre/acm`). Does **not** use legacy `argocd.vihresearchlabs.ai` or other prod names.

### Prerequisites

1. **`infra-live/prod/pre/acm`** applied — certificate **Issued** (includes `argocd.platform.vihresearchlabs.ai`).
2. **[AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)** installed on the EKS cluster (IngressClass **`alb`**). Without it, the Argo **Ingress** will not create an ALB.

   ```bash
   # Example: follow EKS docs / Helm install for your region and IAM policy
   # https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
   ```

3. **`infra-live/prod/application/argocd`** applied with defaults (`ARGOCD_ENABLE_INGRESS` defaults to **`true`**). TLS terminates on **ALB**; pods use HTTP (`server.insecure`).

### DNS

After the Ingress is ready, get the ALB hostname:

```bash
kubectl -n argocd get ingress argocd-server
```

**Option A — Terraform (recommended):** apply **`infra-live/prod/post/route53-argocd`** after the ALB exists (requires **AWS Load Balancer Controller** so the Ingress has an address). Set `VIH_ROUTE53_ZONE_VIHRESEARCHLABS` and either **`VIH_ARGOCD_ALB_ARN`** (best) or **`VIH_ARGOCD_ALB_DNS`** (+ optional `VIH_ARGOCD_ALB_ZONE_ID` for non-default regions). See repo root **`README.md`** env table.

**Option B — Console:** In **Route 53** (zone `vihresearchlabs.ai`), create an **A record (alias)** for **`argocd.platform.vihresearchlabs.ai`** → the **Argo ALB**, or a **CNAME** to that ALB’s DNS name.

Find ALB ARN (example):

```bash
aws elbv2 describe-load-balancers --region us-east-1 \
  --query "LoadBalancers[?DNSName==\`$(kubectl -n argocd get ingress argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')\`].LoadBalancerArn" \
  --output text
```

### Disable custom domain (temporary)

Use a raw LoadBalancer service only:

```bash
export ARGOCD_ENABLE_INGRESS=false
# optional: export ARGOCD_SERVER_SERVICE_TYPE=LoadBalancer
```

Then `terragrunt apply` in `application/argocd`.
