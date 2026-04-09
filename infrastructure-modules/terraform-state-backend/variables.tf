variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform remote state"
}

variable "tags" {
  type        = map(string)
  description = "Tags for all resources"
  default     = {}
}
