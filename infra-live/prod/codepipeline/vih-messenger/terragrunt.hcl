include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "codestar" {
  config_path = "../../pre/codestar-connection"

  mock_outputs = {
    connection_arn = "arn:aws:codestar-connections:ap-south-1:000000000000:connection/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

dependency "ecr" {
  config_path = "../../application_dependency/ecr"

  mock_outputs = {
    registry_host = "000000000000.dkr.ecr.ap-south-1.amazonaws.com"
    repository_urls = {
      "vih-cpass-php"  = "000000000000.dkr.ecr.ap-south-1.amazonaws.com/vih-cpass-php"
      "vih-nlp"        = "000000000000.dkr.ecr.ap-south-1.amazonaws.com/vih-nlp"
      "vih-messenger"  = "000000000000.dkr.ecr.ap-south-1.amazonaws.com/vih-messenger"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

terraform {
  source = "../../../../infrastructure-modules/codepipeline-service//."
}

inputs = {
  pipeline_name = "vih-messenger"

  codestar_connection_arn = dependency.codestar.outputs.connection_arn
  # Source: https://github.com/vihmessenger/vih-messenger
  full_repository_id = get_env("VIH_GITHUB_REPO_MESSENGER", "vihmessenger/vih-messenger")
  branch_name          = get_env("VIH_GITHUB_BRANCH_MESSENGER", "main")

  ecr_repository_url  = dependency.ecr.outputs.registry_host
  ecr_repository_name = "vih-messenger"
  image_tag             = "latest"

  aws_region = get_env("TG_AWS_REGION", "ap-south-1")

  enable_helm_deploy_stage = false

  buildspec_build = file("${get_terragrunt_dir()}/buildspec-build.yml")

  tags = {
    Service = "vih-messenger"
  }
}
