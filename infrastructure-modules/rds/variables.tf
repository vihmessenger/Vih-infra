variable "identifier" {
  type        = string
  description = "RDS instance identifier (unique in region)"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "engine" {
  type = string
  validation {
    condition     = contains(["mysql", "postgres"], var.engine)
    error_message = "engine must be mysql or postgres."
  }
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "allocated_storage" {
  type    = number
  default = 50
}

variable "database_name" {
  type = string
}

variable "master_username" {
  type = string
}

variable "allowed_security_group_ids" {
  type        = list(string)
  default     = []
  description = "EKS node SGs, etc."
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "Optional CIDRs (e.g. VPC CIDR for bootstrap before EKS SG exists)."
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
