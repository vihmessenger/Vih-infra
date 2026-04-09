include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name = "vih-messenger-prod-eks"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

dependency "acm" {
  config_path = "../../pre/acm"

  mock_outputs = {
    certificate_arn = "arn:aws:acm:us-east-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

terraform {
  source = "../../../../infrastructure-modules/argocd-bootstrap//."
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  aws_region   = get_env("TG_AWS_REGION", "us-east-1")

  argocd_chart_version = get_env("ARGOCD_CHART_VERSION", "7.6.12")
  server_service_type  = get_env("ARGOCD_SERVER_SERVICE_TYPE", "LoadBalancer")

  # HTTPS UI: ALB Ingress (requires AWS Load Balancer Controller on EKS — see k8s/argocd/README.md)
  enable_ingress          = get_env("ARGOCD_ENABLE_INGRESS", "true") == "true"
  ingress_hostname        = get_env("ARGOCD_HOSTNAME", "argocd.platform.vihresearchlabs.ai")
  ingress_certificate_arn = dependency.acm.outputs.certificate_arn

  tags = {}
}
