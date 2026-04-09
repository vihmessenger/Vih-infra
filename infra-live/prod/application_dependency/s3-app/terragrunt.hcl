include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "kms" {
  config_path = "../../pre/kms"

  mock_outputs = {
    key_arn = "arn:aws:kms:ap-south-1:000000000000:key/00000000-0000-0000-0000-000000000000"
    key_id  = "00000000-0000-0000-0000-000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "show", "destroy", "state", "output"]
}

terraform {
  source = "../../../../infrastructure-modules/s3-bucket//."
}

inputs = {
  # Globally unique S3 name; override if wrong account: export VIH_AWS_ACCOUNT_ID=...
  bucket_name = "vih-prod-app-data-${get_env("VIH_AWS_ACCOUNT_ID", "327512370966")}"
  kms_key_arn  = dependency.kms.outputs.key_arn
  tags         = {}
}
