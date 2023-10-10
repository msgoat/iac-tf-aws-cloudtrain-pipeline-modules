locals {
  ecr_image_repos = toset(var.repository_names)
}

resource "aws_ecr_repository" "this" {
  for_each = local.ecr_image_repos
  name = each.value
  encryption_configuration {
    encryption_type = "AES256"
  }
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge({ Name = each.value }, local.module_common_tags)
}

locals {
  ecr_repository_keys = [ for repo in aws_ecr_repository.this : repo.name ]
  ecr_repository_values = [ for repo in aws_ecr_repository.this : {
    name = repo.name
    arn = repo.arn
    registry_id = repo.registry_id
    url = repo.repository_url
  }]
  ecr_repositories_by_name = zipmap(local.ecr_repository_keys, local.ecr_repository_values)
}