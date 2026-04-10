# Production (`infra-live/prod`)

Terraform state keys use the prefix **`prod/`** in the S3 backend (see `root.hcl`).

## Naming

| Item | Value |
|------|--------|
| VPC / resource prefix | `vih-messenger-prod` |
| VPC CIDR | `10.0.0.0/16` |
| EKS cluster | `vih-messenger-prod-eks` |
| CodeStar connection | `vih-messenger-prod-github` |
| S3 app bucket | `vih-messenger-prod-app-data-<ACCOUNT_ID>` (edit `application_dependency/s3-app/terragrunt.hcl`) |

## Git branches (CodePipeline defaults)

| Pipeline | Default branch | Override env |
|----------|----------------|--------------|
| vih-cpass-php | `staging` (Dockerfile) | `VIH_GITHUB_BRANCH` |
| vih-nlp | `nlp_backend_staging` | `VIH_GITHUB_BRANCH_NLP` |
| vih-messenger | `newDesign` (Dockerfile at root) | `VIH_GITHUB_BRANCH_MESSENGER` |

## ACM (TLS)

ACM uses **`*.platform.vihresearchlabs.ai`** only — **does not** overlap legacy names (`api`, `www`, `voicebot`, `exotel`). See `pre/acm/terragrunt.hcl` and `../domain/README.md`. Argo CD: **`argocd.platform.vihresearchlabs.ai`** on **ALB Ingress** — apply **`application/eks-lbc`** (or install LBC manually) before Argo; DNS via **`post/route53-argocd`** (`k8s/argocd/README.md`, `application/eks-lbc/README.md`, `post/route53-argocd/README.md`).

## Apply

From each stack directory (example):

```bash
cd infra-live/prod/pre/network
export VIH_TF_STATE_BUCKET="your-bucket"
terragrunt init && terragrunt apply
```

Follow the numbered order in the repo root **`README.md`**.

Optional: **`post/route53-argocd`** — Route 53 **A alias** for `argocd.platform.vihresearchlabs.ai` → Argo ALB. **`application/eks-lbc`** — Helm-managed **AWS Load Balancer Controller**. If either was created manually, use **`terragrunt import`** per those folders’ `README.md` to sync state.
