# Route 53 — `argocd.platform.vihresearchlabs.ai` → Argo ALB

Creates an **A (alias)** record to the **Application Load Balancer** in front of Argo CD.

## Prerequisites

- **AWS Load Balancer Controller** installed and Argo **Ingress** has an **ADDRESS** (ALB hostname).
- `VIH_ROUTE53_ZONE_VIHRESEARCHLABS` set to the hosted zone ID for `vihresearchlabs.ai`.

## Inputs

| Env / input | Purpose |
|-------------|---------|
| `VIH_ARGOCD_ALB_ARN` | Preferred — Terraform resolves DNS + zone from the ALB |
| `VIH_ARGOCD_ALB_DNS` + `VIH_ARGOCD_ALB_ZONE_ID` | Alternative if you only have the ALB DNS name |

## Record created outside Terraform (import)

If you created the record with AWS CLI or console:

```bash
cd infra-live/prod/post/route53-argocd
export VIH_TF_STATE_BUCKET=…
export VIH_TF_STATE_KMS_KEY_ARN=…
export TG_AWS_REGION=us-east-1
export VIH_ROUTE53_ZONE_VIHRESEARCHLABS=Z09822451LS3YFW1LG2KB
export VIH_ARGOCD_ALB_ARN='arn:aws:elasticloadbalancing:us-east-1:ACCOUNT:loadbalancer/app/…'

terragrunt init
terragrunt import 'aws_route53_record.this[0]' 'ZONEID_argocd.platform.vihresearchlabs.ai_A'
# Example ZONEID: Z09822451LS3YFW1LG2KB — use your hosted zone ID
terragrunt plan
```

Import ID format: `HOSTED_ZONE_ID_RECORDNAME_TYPE` (no trailing dot on name; type `A`).

After import, `terragrunt plan` should show **no changes** if the alias matches.
