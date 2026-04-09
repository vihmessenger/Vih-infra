output "argocd_namespace" {
  value = "argocd"
}

output "argocd_release_name" {
  value = helm_release.argocd.name
}

output "helm_chart_version_applied" {
  value = helm_release.argocd.version
}
