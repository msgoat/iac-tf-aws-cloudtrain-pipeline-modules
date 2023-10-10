resource "aws_ecr_repository" "this" {
  name = var.repository_name
  encryption_configuration {
    encryption_type = "AES256"
  }
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge({ Name = var.repository_name }, local.module_common_tags)
}