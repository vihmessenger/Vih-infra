data "aws_lb" "by_arn" {
  count = var.alb_arn != "" ? 1 : 0
  arn   = var.alb_arn
}

locals {
  use_arn = var.alb_arn != ""
  use_dns = !local.use_arn && var.alb_dns_name != "" && var.alb_hosted_zone_id != ""
  # Hosted zone + one of: ALB ARN, or DNS name + ALB zone id
  create = var.hosted_zone_id != "" && (local.use_arn || local.use_dns)

  alias_dns = local.use_arn ? data.aws_lb.by_arn[0].dns_name : var.alb_dns_name
  alias_zid = local.use_arn ? data.aws_lb.by_arn[0].zone_id : var.alb_hosted_zone_id
}

resource "aws_route53_record" "this" {
  count = local.create ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = local.alias_dns
    zone_id                = local.alias_zid
    evaluate_target_health = true
  }
}
