variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the cluster (Helm value vpcId)"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version (aws-load-balancer-controller chart)"
  default     = "3.2.1"
}

variable "service_account_create" {
  type        = bool
  description = "Set false when IRSA service account already exists (e.g. from eksctl)"
  default     = false
}

variable "service_account_name" {
  type    = string
  default = "aws-load-balancer-controller"
}
