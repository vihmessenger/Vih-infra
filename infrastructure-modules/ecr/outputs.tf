output "repository_urls" {
  value = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  value = { for k, v in aws_ecr_repository.this : k => v.arn }
}

output "registry_host" {
  description = "ECR registry host (account.dkr.ecr.region.amazonaws.com)"
  value       = split("/", aws_ecr_repository.this[sort(keys(aws_ecr_repository.this))[0]].repository_url)[0]
}
