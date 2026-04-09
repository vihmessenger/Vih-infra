include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "codestar" {
  config_path = "../../pre/codestar-connection"

  mock_outputs = {
    connection_arn = "arn:aws:codestar-connections:us-east-1:000000000000:connection/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

dependency "ecr" {
  config_path = "../../application_dependency/ecr"

  mock_outputs = {
    registry_host = "000000000000.dkr.ecr.us-east-1.amazonaws.com"
    repository_urls = {
      "vih-cpass-php"  = "000000000000.dkr.ecr.us-east-1.amazonaws.com/vih-cpass-php"
      "vih-nlp"        = "000000000000.dkr.ecr.us-east-1.amazonaws.com/vih-nlp"
      "vih-messenger"  = "000000000000.dkr.ecr.us-east-1.amazonaws.com/vih-messenger"
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

terraform {
  source = "../../../../infrastructure-modules/codepipeline-service//."
}

inputs = {
  pipeline_name = "vih-cpass-php"

  codestar_connection_arn = dependency.codestar.outputs.connection_arn
  # Source: https://github.com/vihmessenger/vih_cpass_php
  full_repository_id      = get_env("VIH_GITHUB_REPO_CPASS", "vihmessenger/vih_cpass_php")
  branch_name             = get_env("VIH_GITHUB_BRANCH", "main")

  ecr_repository_url  = dependency.ecr.outputs.registry_host
  ecr_repository_name = "vih-cpass-php"
  image_tag             = "latest"

  aws_region = get_env("TG_AWS_REGION", "us-east-1")

  # GitOps: build + push ECR only; Argo CD deploys from Git (see k8s/argocd/).
  enable_helm_deploy_stage = false

  buildspec_build = file("${get_terragrunt_dir()}/buildspec-build.yml")

  tags = {
    Service = "vih-cpass-php"
  }
}
