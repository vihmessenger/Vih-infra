variable "hosted_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID for the parent zone (e.g. vihresearchlabs.ai)."
}

variable "record_name" {
  type        = string
  description = "DNS name to create (e.g. argocd.platform.vihresearchlabs.ai)."
}

variable "alb_arn" {
  type        = string
  description = "Optional. Application Load Balancer ARN — Terraform reads DNS name and canonical zone ID."
  default     = ""
}

variable "alb_dns_name" {
  type        = string
  description = "Use if alb_arn is not set: ALB DNS name from kubectl get ingress / AWS console."
  default     = ""
}

variable "alb_hosted_zone_id" {
  type        = string
  description = "Required with alb_dns_name: canonical hosted zone ID for the ALB (region-specific). Ignored when alb_arn is set."
  default     = ""
}
