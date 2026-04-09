variable "pipeline_name" {
  type = string
}

variable "codestar_connection_arn" {
  type = string
}

variable "full_repository_id" {
  type        = string
  description = "GitHub org/repo"
}

variable "branch_name" {
  type    = string
  default = "main"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR registry host (account.dkr.ecr.region.amazonaws.com)"
}

variable "ecr_repository_name" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "aws_region" {
  type = string
}

# When false (GitOps default): only Source + Build (Docker push to ECR). Argo CD deploys from Git.
variable "enable_helm_deploy_stage" {
  type        = bool
  description = "If true, add CodeBuild deploy stage (helm/kubectl). Use false for Argo CD."
  default     = false
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name (required only if enable_helm_deploy_stage is true)"
  default     = ""
}

variable "helm_chart_path" {
  type        = string
  description = "Path to chart in infra repo (deploy stage only)"
  default     = ""
}

variable "helm_release_name" {
  type    = string
  default = ""
}

variable "k8s_namespace" {
  type    = string
  default = "vih-messenger"
}

variable "buildspec_build" {
  type        = string
  description = "CodeBuild buildspec YAML for Docker build + ECR push"
}

variable "buildspec_deploy" {
  type        = string
  description = "CodeBuild buildspec for kubeconfig + helm (only if enable_helm_deploy_stage)"
  default     = ""
}

variable "infra_git_clone_url" {
  type        = string
  description = "HTTPS URL for infra repo clone (deploy stage only)"
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
