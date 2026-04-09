locals {
  environment = "prod"
  aws_region  = get_env("TG_AWS_REGION", "us-east-1")
  project     = "vih-messenger"

  common_tags = {
    Project     = "vih-messenger"
    Environment = "prod"
    ManagedBy   = "terraform"
  }

  state_bucket      = get_env("VIH_TF_STATE_BUCKET", "REPLACE_STATE_BUCKET")
  state_kms_key_arn = get_env("VIH_TF_STATE_KMS_KEY_ARN", "")
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "s3" {}
    }
  EOF
}

remote_state {
  backend = "s3"
  config = merge(
    {
      bucket         = local.state_bucket
      key            = "${local.environment}/${path_relative_to_include()}/terraform.tfstate"
      region         = local.aws_region
      encrypt        = true
      use_lockfile   = true
    },
    local.state_kms_key_arn != "" ? { kms_key_id = local.state_kms_key_arn } : {}
  )
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    # Provider only — each module supplies terraform/required_providers in versions.tf
    provider "aws" {
      region = "${local.aws_region}"

      default_tags {
        tags = {
          Project     = "${local.project}"
          Environment = "${local.environment}"
          ManagedBy   = "terraform"
        }
      }
    }
  EOF
}

terraform {
  extra_arguments "lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}
