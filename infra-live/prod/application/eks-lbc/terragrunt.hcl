include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../pre/network"

  mock_outputs = {
    vpc_id             = "vpc-mock00000000000000000"
    vpc_cidr_block     = "10.0.0.0/16"
    private_subnet_ids = ["subnet-mockaaaaaaaa"]
    public_subnet_ids  = ["subnet-mockcccccccc"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name                       = "vih-messenger-prod-eks"
    cluster_endpoint                   = "https://mock"
    cluster_certificate_authority_data = "bW9jaw=="
    cluster_oidc_issuer_url            = "https://mock"
    oidc_provider_arn                  = "arn:aws:iam::000000000000:oidc-provider/mock"
    node_security_group_id             = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

terraform {
  source = "../../../../infrastructure-modules/eks-aws-lbc-helm//."
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  aws_region   = get_env("TG_AWS_REGION", "us-east-1")
  vpc_id       = dependency.vpc.outputs.vpc_id

  # Pin to match chart already deployed; bump when upgrading LBC.
  chart_version = get_env("VIH_LBC_CHART_VERSION", "3.2.1")

  # IRSA SA created separately (e.g. eksctl create iamserviceaccount …)
  service_account_create = false
  service_account_name   = "aws-load-balancer-controller"
}
