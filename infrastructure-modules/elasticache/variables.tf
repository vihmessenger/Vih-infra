variable "replication_group_id" {
  type        = string
  description = "ElastiCache replication group ID (alphanumeric, hyphen)"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "node_type" {
  type    = string
  default = "cache.t3.micro"
}

variable "engine_version" {
  type    = string
  default = "7.1"
}

variable "allowed_security_group_ids" {
  type    = list(string)
  default = []
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
