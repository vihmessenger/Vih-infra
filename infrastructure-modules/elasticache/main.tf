resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.replication_group_id}-subnet"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.replication_group_id}-subnet" })
}

resource "aws_security_group" "this" {
  name        = "${var.replication_group_id}-redis-sg"
  description = "Redis ${var.replication_group_id}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      from_port       = 6379
      to_port         = 6379
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.replication_group_id}-redis-sg" })

  lifecycle {
    precondition {
      condition     = length(var.allowed_security_group_ids) > 0 || length(var.allowed_cidr_blocks) > 0
      error_message = "Set allowed_security_group_ids and/or allowed_cidr_blocks."
    }
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.replication_group_id
  description          = "Redis ${var.replication_group_id}"

  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.this.id]

  automatic_failover_enabled = false
  multi_az_enabled           = false
  num_cache_clusters         = 1

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  tags = merge(var.tags, { Name = var.replication_group_id })
}
