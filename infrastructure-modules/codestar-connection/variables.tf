variable "connection_name" {
  type        = string
  description = "Codestar connection name (unique per region)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
