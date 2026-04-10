include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/route53-alb-alias//."
}

inputs = {
  hosted_zone_id = get_env("VIH_ROUTE53_ZONE_VIHRESEARCHLABS", "")
  record_name    = get_env("VIH_PLATFORM_APP_DNS_NAME", "app.platform.vihresearchlabs.ai")

  alb_arn            = get_env("VIH_PLATFORM_APP_ALB_ARN", "")
  alb_dns_name       = get_env("VIH_PLATFORM_APP_ALB_DNS", "")
  alb_hosted_zone_id = get_env("VIH_PLATFORM_APP_ALB_ZONE_ID", "Z35SXDOTRQ7X7K")
}
