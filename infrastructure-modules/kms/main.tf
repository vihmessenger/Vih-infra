resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-kms"
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name_prefix}-app"
  target_key_id = aws_kms_key.this.key_id
}
