include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../infrastructure-modules/ecr//."
}

inputs = {
  repository_names = [
    "vih-cpass-php",
    "vih-nlp",
    "vih-messenger",
  ]
  tags = {}
}
