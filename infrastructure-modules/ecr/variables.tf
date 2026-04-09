variable "repository_names" {
  type        = list(string)
  description = "ECR repository names to create"
}

variable "tags" {
  type    = map(string)
  default = {}
}
