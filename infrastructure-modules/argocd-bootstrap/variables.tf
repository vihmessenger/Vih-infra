variable "cluster_name" {
  type        = string
  description = "EKS cluster name (must exist before apply)"
}

variable "aws_region" {
  type = string
}

variable "argocd_chart_version" {
  type        = string
  description = "argo-cd Helm chart version (https://github.com/argoproj/argo-helm/releases)"
  default     = "7.6.12"
}

variable "server_service_type" {
  type        = string
  description = "Argo CD server Service type when ingress is disabled (e.g. LoadBalancer)"
  default     = "LoadBalancer"
}

variable "enable_ingress" {
  type        = bool
  description = "If true, expose Argo CD via Ingress (e.g. AWS ALB). Requires AWS Load Balancer Controller on the cluster."
  default     = false

  validation {
    condition     = !var.enable_ingress || (var.ingress_hostname != "" && var.ingress_certificate_arn != "")
    error_message = "When enable_ingress is true, ingress_hostname and ingress_certificate_arn must be set."
  }
}

variable "ingress_hostname" {
  type        = string
  description = "FQDN for Argo CD (e.g. argocd.example.com). Used in Ingress and argocd-cm url."
  default     = ""
}

variable "ingress_certificate_arn" {
  type        = string
  description = "ACM certificate ARN (same region as EKS) for HTTPS on ALB."
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
