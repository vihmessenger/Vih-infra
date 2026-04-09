locals {
  port = var.engine == "mysql" ? 3306 : 5432
}

resource "random_password" "master" {
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.identifier}-subnet" })
}

resource "aws_security_group" "this" {
  name        = "${var.identifier}-rds-sg"
  description = "RDS ${var.identifier}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? [1] : []
    content {
      description     = "From security groups"
      from_port       = local.port
      to_port         = local.port
      protocol        = "tcp"
      security_groups = var.allowed_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      description = "From CIDR"
      from_port   = local.port
      to_port     = local.port
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

  tags = merge(var.tags, { Name = "${var.identifier}-rds-sg" })

  lifecycle {
    precondition {
      condition     = length(var.allowed_security_group_ids) > 0 || length(var.allowed_cidr_blocks) > 0
      error_message = "Set allowed_security_group_ids and/or allowed_cidr_blocks."
    }
  }
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.allocated_storage * 2
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.master_username
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  multi_az               = var.multi_az
  publicly_accessible    = false
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = false
  backup_retention_period = 7

  tags = merge(var.tags, { Name = var.identifier })
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.identifier}-db-credentials"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = var.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.database_name
  })
}
