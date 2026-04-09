include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/vpc//."
}

inputs = {
  name_prefix = "vih-messenger-prod"
  cidr        = "10.0.0.0/16"
  az_count    = 2
  region      = get_env("TG_AWS_REGION", "us-east-1")
  tags        = {}
}
