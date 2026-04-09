variable "name_prefix" {
  type        = string
  description = "Prefix for KMS alias (alphanumeric, hyphens)"
}

variable "description" {
  type        = string
  description = "KMS key description"
  default     = "Application encryption key"
}

variable "tags" {
  type    = map(string)
  default = {}
}
