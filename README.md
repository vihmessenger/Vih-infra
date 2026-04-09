# Vih-infra

AWS infrastructure for **ViH Messenger**: Terraform, Terragrunt, EKS, and **Argo CD** GitOps.

**Repo · org:** [vihmessenger/Vih-infra](https://github.com/vihmessenger/Vih-infra) · [vihmessenger](https://github.com/vihmessenger)

| | |
|---|---|
| **State** | S3 + KMS · lockfile via Terraform `use_lockfile` (≥ 1.10) |
| **CI** | CodePipeline → CodeBuild → **ECR** |
| **CD** | **Argo CD** ← `k8s/charts/*` + `k8s/argocd/applications/*` |

App behaviour is documented in the monorepo **`ARCHITECTURE.md`**; this repo is **how** it runs on AWS.

---

## Clone

```bash
git clone https://github.com/vihmessenger/Vih-infra.git && cd Vih-infra
```

SSH (e.g. host alias `github-vihmessenger` in `~/.ssh/config`):

```bash
git clone git@github-vihmessenger:vihmessenger/Vih-infra.git && cd Vih-infra
```

---

## Layout

```
Vih-infra/
├── README.md
├── .gitignore
├── infra-bootstrap/
│   └── terragrunt.hcl                 # state bucket + KMS (local tfstate for this stack)
├── infra-live/
│   ├── domain/
│   │   └── README.md                  # DNS, ACM, *.platform.vihresearchlabs.ai
│   └── prod/
│       ├── root.hcl                   # remote backend + provider
│       ├── README.md
│       ├── pre/
│       │   ├── kms/terragrunt.hcl
│       │   ├── network/terragrunt.hcl
│       │   ├── codestar-connection/terragrunt.hcl
│       │   └── acm/terragrunt.hcl
│       ├── application_dependency/
│       │   ├── ecr/terragrunt.hcl
│       │   ├── rds-mysql/terragrunt.hcl
│       │   ├── rds-postgres/terragrunt.hcl
│       │   ├── elasticache-redis/terragrunt.hcl
│       │   ├── s3-app/terragrunt.hcl
│       │   └── waf/terragrunt.hcl
│       ├── application/
│       │   ├── eks/terragrunt.hcl
│       │   ├── eks-lbc/terragrunt.hcl          # AWS Load Balancer Controller (Helm)
│       │   └── argocd/terragrunt.hcl
│       ├── post/
│       │   └── route53-argocd/terragrunt.hcl   # optional: public DNS → Argo ALB
│       └── codepipeline/
│           ├── vih-cpass-php/
│           │   ├── terragrunt.hcl
│           │   └── buildspec-build.yml
│           ├── vih-nlp/
│           │   ├── terragrunt.hcl
│           │   └── buildspec-build.yml
│           └── vih-messenger/
│               ├── terragrunt.hcl
│               └── buildspec-build.yml
├── infrastructure-modules/
│   ├── terraform-state-backend/       # S3 + KMS (state only)
│   ├── kms/
│   ├── vpc/
│   ├── ecr/
│   ├── rds/
│   ├── elasticache/
│   ├── codestar-connection/
│   ├── codepipeline-service/
│   ├── acm-alb/
│   ├── s3-bucket/
│   ├── waf-alb/
│   ├── eks/
│   ├── argocd-bootstrap/
│   ├── eks-aws-lbc-helm/              # Helm: AWS Load Balancer Controller
│   └── route53-alb-alias/
└── k8s/
    ├── argocd/
    │   ├── README.md
    │   └── applications/
    │       ├── vih-cpass-php.yaml
    │       ├── vih-nlp.yaml
    │       └── vih-messenger.yaml
    └── charts/
        ├── vih-cpass-php/             # Chart.yaml, values.yaml, templates/
        ├── vih-nlp/
        └── vih-messenger/
```

Each `infrastructure-modules/<name>/` has Terraform `*.tf`. Not committed: `.terraform/`, `.terragrunt-cache/`, `*.tfstate` (see `.gitignore`).

---

## Requirements

Terraform **≥ 1.10** · Terragrunt **≥ 0.50** · AWS CLI · `kubectl` (after EKS)

For Argo on **ALB**: apply **`application/eks-lbc`** (Helm) after **`application/eks`**, or install [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) manually — before Argo **Ingress** can provision an ALB (`k8s/argocd/README.md`, `application/eks-lbc/README.md`).

---

## Environment

Set before `terragrunt` under `infra-live/prod/`:

| Variable | Notes |
|----------|--------|
| `VIH_TF_STATE_BUCKET` | **Required** — from bootstrap |
| `VIH_TF_STATE_KMS_KEY_ARN` | Optional; recommended |
| `VIH_ROUTE53_ZONE_VIHRESEARCHLABS` | Hosted zone ID for ACM DNS validation and `post/route53-argocd` |
| `VIH_ARGOCD_ALB_ARN` | (optional) Argo Ingress ALB ARN for `post/route53-argocd` — preferred |
| `VIH_ARGOCD_ALB_DNS` | (optional) ALB DNS name if not using ARN |
| `VIH_ARGOCD_ALB_ZONE_ID` | (optional) ALB canonical zone ID; default is us-east-1 when using DNS only |
| `VIH_AWS_ACCOUNT_ID` | S3 app bucket suffix (default in `s3-app` terragrunt) |
| `TG_AWS_REGION` | Default `us-east-1` |

---

## Bootstrap (once per account)

```bash
cd infra-bootstrap
export VIH_TF_STATE_BUCKET="your-unique-bucket-name"
export TG_AWS_REGION="${TG_AWS_REGION:-us-east-1}"
terragrunt init && terragrunt apply && terragrunt output
```

Then export `VIH_TF_STATE_BUCKET` (and optional KMS ARN) for all **`infra-live/prod`** applies.

---

## Apply order (`infra-live/prod/`)

Paths are relative to `infra-live/prod/`. Details: **`infra-live/prod/README.md`**. DNS/ACM: **`infra-live/domain/README.md`**.

1. `pre/kms` → `pre/network` → `pre/codestar-connection` → **authorize** GitHub in AWS Console  
2. `pre/acm` — `*.platform.vihresearchlabs.ai`  
3. `application_dependency/ecr` → `rds-mysql` → `rds-postgres` → `elasticache-redis` → `s3-app` → `waf`  
4. `application/eks`  
5. `application/eks-lbc` — **AWS Load Balancer Controller** (Helm); IRSA can be created first (`eksctl` / docs). If LBC was installed manually, **`terragrunt import`** — see `application/eks-lbc/README.md`  
6. `application/argocd`  
7. **`post/route53-argocd`** (optional) — Route 53 **A alias** `argocd.platform…` → Argo ALB (`VIH_ARGOCD_ALB_ARN` or DNS + zone). If DNS was created manually, **`terragrunt import`** — see `post/route53-argocd/README.md`  
8. `codepipeline/vih-cpass-php`, `vih-nlp`, `vih-messenger`

```bash
cd infra-live/prod/pre/network
terragrunt init && terragrunt apply
```

Argo UI (after DNS): `https://argocd.platform.vihresearchlabs.ai` · `kubectl apply -f k8s/argocd/applications/`

---

## Conventions

- Remote state key: `${environment}/${path}/terraform.tfstate` in `root.hcl`  
- `include "root" { path = find_in_parent_folders("root.hcl") }`  
- `dependency` blocks use `mock_outputs` so `plan` works without upstream state

---

## Modules (summary)

| Module | Role |
|--------|------|
| `terraform-state-backend` | Bootstrap: state S3 + KMS |
| `kms`, `vpc`, `acm-alb`, `waf-alb` | App KMS, network, TLS, WAF |
| `ecr`, `eks`, `rds`, `elasticache`, `s3-bucket` | Registry, cluster, data |
| `codestar-connection`, `codepipeline-service` | GitHub → build → ECR |
| `argocd-bootstrap` | Argo CD Helm |
| `route53-alb-alias` | Route 53 A record (alias) to an existing ALB |
| `eks-aws-lbc-helm` | Helm release: AWS Load Balancer Controller |

Optional: Helm deploy from pipeline via `enable_helm_deploy_stage` in `codepipeline-service` (default off).

---

## Observability

Default: **CloudWatch** / **Container Insights** (no in-cluster Prometheus).

---

## More docs

| | |
|---|---|
| `infra-live/prod/README.md` | Prod names & pipeline env |
| `infra-live/domain/README.md` | Route 53 & platform hostnames |
| `k8s/argocd/README.md` | Argo, Ingress, LBC |

---

**Internal** — [vihmessenger](https://github.com/vihmessenger) on GitHub.
