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
  source = "../../../../infrastructure-modules/elasticache//."
}

inputs = {
  replication_group_id = "vih-messenger-prod-redis"

  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids

  node_type = "cache.t3.micro"

  allowed_security_group_ids = []
  allowed_cidr_blocks          = [dependency.vpc.outputs.vpc_cidr_block]

  tags = {
    Service = "redis"
  }
}
