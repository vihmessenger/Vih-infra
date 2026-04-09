# VIH-INFRA — ViH Messenger (Terraform + Terragrunt + Argo CD)

AWS IaC monorepo: **S3 + KMS** remote state (**S3 native locking** via `use_lockfile`, **no DynamoDB**), reusable **modules**, **Terragrunt** per environment.

**Infra repo (GitOps / Helm):** [github.com/vihmessenger/Vih-infra](https://github.com/vihmessenger/Vih-infra) — **`k8s/charts/*`** aur Argo manifests yahi par. **Org:** [vihmessenger](https://github.com/vihmessenger).

**SSH clone** (uses `github-vihmessenger` host from `~/.ssh/config` + **Deba-VIH-MESSENGER** key):  
`git clone git@github-vihmessenger:vihmessenger/Vih-infra.git`

**GitOps:** **Argo CD** deploys workloads from Git (`k8s/charts/*`, `k8s/argocd/applications/*`). **CodePipeline** only **builds Docker images and pushes to ECR** (no Helm deploy in CI).

## Architecture alignment

Message flow in `ARCHITECTURE.md` (Enterprise → CPaaS → NLP → WebSocket / FCM → webhooks) is unchanged. **Only the deploy mechanism** changes: **Argo CD** syncs Kubernetes state from Git instead of CodeBuild running `helm upgrade`.

**AWS diagrams (VPC, EKS, data, CI/CD, GitOps):** see **`ARCHITECTURE_AWS.md`**. A **PNG with AWS icons** is at **`docs/figures/vih-aws-architecture.png`** (regenerate with **`python3 scripts/generate_aws_diagram.py`**).

## Requirements

- Terraform **>= 1.10** (S3 `use_lockfile`)
- Terragrunt **>= 0.50**
- AWS CLI + credentials

## 1) Bootstrap (once per account)

```bash
cd infra-bootstrap
export VIH_TF_STATE_BUCKET="your-globally-unique-state-bucket-name"
export TG_AWS_REGION="${TG_AWS_REGION:-ap-south-1}"
terragrunt init
terragrunt apply
terragrunt output
```

Export for all live stacks:

```bash
export VIH_TF_STATE_BUCKET="..."
export VIH_TF_STATE_KMS_KEY_ARN="..."   # optional but recommended
```

## 2) GitHub CodeStar connection

After `pre/codestar-connection` apply, complete the GitHub connection in **AWS Console → Developer Tools → Connections**.

## 3) Apply order (production)

All live stacks are under **`infra-live/prod/`**. State keys use prefix **`prod/`**. See **`infra-live/prod/README.md`** for naming and pipeline branch overrides.

1. `infra-live/prod/pre/kms` — **application KMS** (separate from state-bucket KMS in bootstrap)
2. `infra-live/prod/pre/network`
3. `infra-live/prod/pre/codestar-connection`
4. `infra-live/prod/pre/acm` — **New** hostnames under **`*.platform.vihresearchlabs.ai`** (does **not** reuse `api` / `www` / `voicebot` / `exotel`); set **`VIH_ROUTE53_ZONE_VIHRESEARCHLABS`** when the zone is in the same account (see `infra-live/domain/README.md`)
5. `infra-live/prod/application_dependency/ecr`
6. `infra-live/prod/application_dependency/rds-mysql`
7. `infra-live/prod/application_dependency/rds-postgres`
8. `infra-live/prod/application_dependency/elasticache-redis`
9. `infra-live/prod/application_dependency/s3-app` — unique bucket name; uses **app KMS** for SSE-KMS
10. `infra-live/prod/application_dependency/waf` — **WAF regional** ACL (attach to ALB in app layer)
11. `infra-live/prod/application/eks`
12. **(Before Argo with domain)** Install [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) on the cluster if you want **`argocd.vihresearchlabs.ai`** (see **`k8s/argocd/README.md`**).  
13. **`infra-live/prod/application/argocd`** — Argo CD via Helm (ALB Ingress + ACM when enabled)
14. `infra-live/prod/codepipeline/vih-cpass-php`, `vih-nlp`, and **`vih-messenger`** — **ECR push only** (default Git branches **`main`**; override with **`VIH_GITHUB_BRANCH`**, **`VIH_GITHUB_BRANCH_NLP`**, **`VIH_GITHUB_BRANCH_MESSENGER`**)

Then:

- Argo CD UI: **`https://argocd.platform.vihresearchlabs.ai`** (after DNS → new ALB) or `kubectl -n argocd get ingress` / `get svc` if Ingress/LB disabled.
- Register Git repo in Argo CD; edit `k8s/argocd/applications/*.yaml` **repoURL**; `kubectl apply -f k8s/argocd/applications/`.

See **`k8s/argocd/README.md`**.

## Remote state key pattern

`"${environment}/${path_relative_to_include()}/terraform.tfstate"` — in each env **`root.hcl`**.

## Terragrunt conventions

- `include "root" { path = find_in_parent_folders("root.hcl") }`
- **`dependency`** blocks use **`mock_outputs`** so `terragrunt plan` works before upstream applies.

## CodePipeline vs Argo CD

| Concern | Implementation |
|---------|----------------|
| **Build & push image** | CodePipeline + CodeBuild → **ECR** |
| **Deploy to EKS** | **Argo CD** sync from Git (Helm charts under `k8s/charts/`) |
| **Optional legacy Helm in CI** | Set `enable_helm_deploy_stage = true` in `codepipeline-service` (not used for default ViH flow) |

## Optional: Helm deploy from CodePipeline

If you ever need CodeBuild to run `helm upgrade` again, set **`enable_helm_deploy_stage = true`** in the pipeline module inputs and supply **`buildspec_deploy`**, **`cluster_name`**, etc.

## No in-cluster Prometheus

Use **CloudWatch** / **Container Insights** unless you add observability later.

## What the “optional” modules are for (significance)

| Module / stack | Role |
|----------------|------|
| **`terraform-state-backend`** (bootstrap) | KMS + S3 for **Terraform state** only — not for app data. |
| **`kms`** (`pre/kms`) | **Customer-managed key** for **application** workloads: encrypt S3 objects, optional RDS/ElastiCache CMK usage, Secrets Manager, etc. **Separate** from bootstrap state KMS. |
| **`acm-alb`** (`pre/acm`) | **TLS** for **`*.platform.vihresearchlabs.ai`** (API, WS, app, Argo) — separate from legacy `api` / `www` / etc. Wire **Route53** when the zone is in the same account. |
| **`s3-bucket`** (`s3-app`) | **Durable object storage** (uploads, exports, static assets) with **SSE-KMS** using the app KMS key. |
| **`waf-alb`** (`waf`) | **AWS WAF** Web ACL (e.g. AWS Managed Rules) — attach to **ALB** to reduce abuse and common web attacks on public endpoints. |

## Layout

See **`TREE.md`**.
