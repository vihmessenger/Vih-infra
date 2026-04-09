include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/acm-alb//."
}

inputs = {
  # New EKS / GitOps stack only — do NOT reuse hostnames already in production (api, www, voicebot, exotel, apex).
  # All names live under *.platform.vihresearchlabs.ai
  domain_name               = "api.platform.vihresearchlabs.ai"
  subject_alternative_names = [
    "ws.platform.vihresearchlabs.ai",
    "app.platform.vihresearchlabs.ai",
    "argocd.platform.vihresearchlabs.ai",
  ]
  route53_zone_id           = get_env("VIH_ROUTE53_ZONE_VIHRESEARCHLABS", "")
  tags                      = {}
}
