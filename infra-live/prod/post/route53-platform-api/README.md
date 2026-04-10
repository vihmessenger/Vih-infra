# Route 53 — `api.platform.vihresearchlabs.ai` → NLP (Django) ALB

After the **vih-nlp** Ingress has an **ADDRESS**, point this hostname at that ALB.

## Prerequisites

- `VIH_ROUTE53_ZONE_VIHRESEARCHLABS` = hosted zone ID for `vihresearchlabs.ai`
- ACM includes **`api.platform.vihresearchlabs.ai`** (`pre/acm`)

## ALB for this app

```bash
kubectl -n vih-messenger get ingress vih-nlp -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}'
```

Resolve ARN (same pattern as `route53-platform-app/README.md`).

## Apply

```bash
export VIH_TF_STATE_BUCKET=…
export VIH_ROUTE53_ZONE_VIHRESEARCHLABS=Zxxxxxxxx
export VIH_PLATFORM_API_ALB_ARN='arn:aws:elasticloadbalancing:us-east-1:…:loadbalancer/app/…'
cd infra-live/prod/post/route53-platform-api
terragrunt apply
```

Override with `VIH_PLATFORM_API_DNS_NAME` if needed.
