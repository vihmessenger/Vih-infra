include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/kms//."
}

inputs = {
  name_prefix = "vih-prod"
  description   = "Application encryption (dev)"
  tags          = {}
}
