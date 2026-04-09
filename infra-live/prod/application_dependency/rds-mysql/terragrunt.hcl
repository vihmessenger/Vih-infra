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
  source = "../../../../infrastructure-modules/rds//."
}

inputs = {
  identifier = "vih-messenger-prod-mysql"

  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids

  engine         = "mysql"
  engine_version = "8.0"
  database_name  = "gbcdata"
  master_username = "vihadmin"

  allowed_security_group_ids = []
  allowed_cidr_blocks          = [dependency.vpc.outputs.vpc_cidr_block]

  instance_class      = "db.t3.medium"
  allocated_storage   = 50
  skip_final_snapshot = true
  multi_az            = false

  tags = {
    Service = "mysql"
  }
}
