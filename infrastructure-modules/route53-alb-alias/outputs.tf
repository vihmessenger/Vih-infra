output "fqdn" {
  description = "FQDN of the record (if created)."
  value       = try(aws_route53_record.this[0].fqdn, null)
}

output "record_created" {
  description = "Whether a Route 53 record was created (requires ALB inputs)."
  value       = local.create
}
