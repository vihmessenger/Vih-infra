variable "name_prefix" {
  type        = string
  description = "Name prefix for VPC resources"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "region" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
