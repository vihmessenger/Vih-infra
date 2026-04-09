# Run once per AWS account: S3 remote state bucket + KMS encryption.
# State for this bootstrap stack is local (see generated backend).
# Then: export VIH_TF_STATE_BUCKET and VIH_TF_STATE_KMS_KEY_ARN for infra-live.

terraform {
  source = "../infrastructure-modules/terraform-state-backend//."
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      backend "local" {
        path = "terraform.tfstate"
      }
    }
  EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${get_env("TG_AWS_REGION", "ap-south-1")}"
    }
  EOF
}

inputs = {
  bucket_name = get_env("VIH_TF_STATE_BUCKET", "REPLACE_WITH_GLOBALLY_UNIQUE_BUCKET_NAME")
  tags = {
    Purpose = "terraform-remote-state"
  }
}
