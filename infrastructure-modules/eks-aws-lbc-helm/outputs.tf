output "release_name" {
  value = helm_release.aws_load_balancer_controller.name
}

output "release_namespace" {
  value = helm_release.aws_load_balancer_controller.namespace
}
