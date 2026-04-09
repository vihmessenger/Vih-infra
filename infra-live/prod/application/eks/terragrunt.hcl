include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../pre/network"

  mock_outputs = {
    vpc_id             = "vpc-mock00000000000000000"
    vpc_cidr_block     = "10.0.0.0/16"
    private_subnet_ids = ["subnet-mockaaaaaaaa", "subnet-mockbbbbbbbb"]
    public_subnet_ids    = ["subnet-mockcccccccc", "subnet-mockdddddddd"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

terraform {
  source = "../../../../infrastructure-modules/eks//."
}

inputs = {
  cluster_name = "vih-messenger-prod-eks"
  # AWS EKS allows only one Kubernetes minor version upgrade per operation.
  # From 1.29: apply 1.30 → then 1.31 → … → target (e.g. 1.35), one bump per apply.
  cluster_version = "1.30"

  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  eks_managed_node_groups = {
    default = {
      name           = "default"
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 6
      desired_size   = 2
    }
  }

  tags = {}
}
