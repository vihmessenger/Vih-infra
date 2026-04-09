# Directory tree (summary)

```
VIH-INFRA/
├── infra-bootstrap/terragrunt.hcl
├── infrastructure-modules/
│   ├── terraform-state-backend/   # S3 state bucket + KMS (Terraform state only)
│   ├── kms/                       # App KMS (RDS secrets, S3 SSE-KMS, etc.)
│   ├── argocd-bootstrap/
│   ├── vpc/
│   ├── ecr/
│   ├── rds/
│   ├── elasticache/
│   ├── codestar-connection/
│   ├── acm-alb/                   # TLS certs for ALB / public endpoints
│   ├── s3-bucket/
│   ├── waf-alb/
│   ├── eks/
│   └── codepipeline-service/
├── infra-live/prod/               # production only; state key prefix prod/
│   ├── root.hcl
│   ├── pre/
│   ├── application_dependency/
│   ├── application/
│   └── codepipeline/
├── infra-live/domain/README.md
├── k8s/
│   ├── charts/
│   └── argocd/
└── README.md
```
