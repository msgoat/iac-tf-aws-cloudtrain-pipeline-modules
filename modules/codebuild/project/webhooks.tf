locals {
  projects_with_webhook = [for p in var.projects : p if p.add_webhook ]
  projects_with_webhook_names = [for p in local.projects_with_webhook : p.name ]
  projects_with_webhook_by_name = zipmap(local.projects_with_webhook_names, local.projects_with_webhook)
}

resource "aws_codebuild_webhook" "projects" {
  for_each     = local.projects_with_webhook_by_name
  project_name = aws_codebuild_project.projects[each.key].name
  build_type   = "BUILD"

  filter_group {

    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "main"
    }
  }
}