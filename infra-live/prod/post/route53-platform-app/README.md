# Route 53 — `app.platform.vihresearchlabs.ai` → Messenger (frontend) ALB

After the **vih-messenger** Ingress has an **ADDRESS** (from AWS Load Balancer Controller), point this hostname at that ALB.

## Prerequisites

- `VIH_ROUTE53_ZONE_VIHRESEARCHLABS` = hosted zone ID for `vihresearchlabs.ai`
- ACM already includes **`app.platform.vihresearchlabs.ai`** (`pre/acm`)

## ALB for this app

```bash
kubectl -n vih-messenger get ingress vih-messenger -o jsonpath='{.status.loadBalancer.ingress[0].hostname}{"\n"}"
```

Then resolve ARN (example):

```bash
ALB_HOST="$(kubectl -n vih-messenger get ingress vih-messenger -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
aws elbv2 describe-load-balancers --region us-east-1 \
  --query "LoadBalancers[?DNSName==\`$ALB_HOST\`].LoadBalancerArn" --output text
```

## Apply

```bash
export VIH_TF_STATE_BUCKET=…
export VIH_ROUTE53_ZONE_VIHRESEARCHLABS=Zxxxxxxxx
export VIH_PLATFORM_APP_ALB_ARN='arn:aws:elasticloadbalancing:us-east-1:…:loadbalancer/app/…'
cd infra-live/prod/post/route53-platform-app
terragrunt apply
```

Override DNS name with `VIH_PLATFORM_APP_DNS_NAME` if needed.
