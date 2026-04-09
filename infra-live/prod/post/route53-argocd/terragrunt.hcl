include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/route53-alb-alias//."
}

inputs = {
  hosted_zone_id = get_env("VIH_ROUTE53_ZONE_VIHRESEARCHLABS", "")
  record_name    = get_env("VIH_ARGOCD_DNS_NAME", "argocd.platform.vihresearchlabs.ai")

  # Prefer ALB ARN (resolves DNS + zone automatically). Example after LBC + Ingress:
  #   aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(DNSName, `k8s-argocd`)].LoadBalancerArn" --output text
  alb_arn = get_env("VIH_ARGOCD_ALB_ARN", "")

  # Or set DNS name + zone ID (us-east-1 ALB default zone shown; override for other regions).
  alb_dns_name         = get_env("VIH_ARGOCD_ALB_DNS", "")
  alb_hosted_zone_id   = get_env("VIH_ARGOCD_ALB_ZONE_ID", "Z35SXDOTRQ7X7K")
}
