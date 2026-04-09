variable "bucket_name" {
  type = string
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "If empty, SSE-S3; else SSE-KMS"
}

variable "tags" {
  type    = map(string)
  default = {}
}
