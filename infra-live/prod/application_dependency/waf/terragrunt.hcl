include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/waf-alb//."
}

inputs = {
  name_prefix = "vih-prod"
  tags        = {}
}
