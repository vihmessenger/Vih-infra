include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/codestar-connection//."
}

inputs = {
  connection_name = "vih-messenger-prod-github"
  tags            = {}
}
