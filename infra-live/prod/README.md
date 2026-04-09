# Production (`infra-live/prod`)

Terraform state keys use the prefix **`prod/`** in the S3 backend (see `root.hcl`).

## Naming

| Item | Value |
|------|--------|
| VPC / resource prefix | `vih-prod` |
| VPC CIDR | `10.0.0.0/16` |
| EKS cluster | `vih-prod-eks` |
| CodeStar connection | `vih-prod-github` |
| S3 app bucket | `vih-prod-app-data-<ACCOUNT_ID>` (edit `application_dependency/s3-app/terragrunt.hcl`) |

## Git branches (CodePipeline defaults)

| Pipeline | Default branch | Override env |
|----------|----------------|--------------|
| vih-cpass-php | `main` | `VIH_GITHUB_BRANCH` |
| vih-nlp | `main` | `VIH_GITHUB_BRANCH_NLP` |
| vih-messenger | `main` | `VIH_GITHUB_BRANCH_MESSENGER` |

## ACM (TLS)

ACM uses **`*.platform.vihresearchlabs.ai`** only — **does not** overlap legacy names (`api`, `www`, `voicebot`, `exotel`). See `pre/acm/terragrunt.hcl` and `../domain/README.md`. Argo CD: **`argocd.platform.vihresearchlabs.ai`** on **ALB Ingress** (install **AWS Load Balancer Controller** on EKS first — `k8s/argocd/README.md`).

## Apply

From each stack directory (example):

```bash
cd infra-live/prod/pre/network
export VIH_TF_STATE_BUCKET="your-bucket"
terragrunt init && terragrunt apply
```

Follow the numbered order in the repo root **`README.md`**.
