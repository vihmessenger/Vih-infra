variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type        = string
  description = "EKS control plane version. Upgrades: one minor version per apply (AWS limit)."
  default     = "1.35"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "eks_managed_node_groups" {
  type = any
  default = {
    default = {
      name           = "default"
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 6
      desired_size   = 2
    }
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
