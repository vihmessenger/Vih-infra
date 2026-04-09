locals {
  # TLS terminates at ALB; pods serve HTTP
  server_service_type = var.enable_ingress ? "ClusterIP" : var.server_service_type
}

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      server_service_type       = local.server_service_type
      enable_ingress            = var.enable_ingress
      ingress_hostname          = var.ingress_hostname
      ingress_certificate_arn   = var.ingress_certificate_arn
    })
  ]
}
