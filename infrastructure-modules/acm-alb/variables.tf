variable "domain_name" {
  type        = string
  description = "Primary domain for ACM certificate (e.g. api.example.com)"
}

variable "subject_alternative_names" {
  type        = list(string)
  default     = []
  description = "Optional SANs"
}

variable "route53_zone_id" {
  type        = string
  default     = ""
  description = "If set, create DNS validation records in Route53"
}

variable "tags" {
  type    = map(string)
  default = {}
}
