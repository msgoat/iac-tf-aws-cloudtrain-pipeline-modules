locals {
  project_names    = [for p in var.projects : p.name]
  projects_by_name = zipmap(local.project_names, var.projects)
}

resource "aws_codebuild_project" "projects" {
  for_each      = local.projects_by_name
  name          = each.key
  description   = each.value.description
  service_role  = aws_iam_role.project[each.key].arn
  badge_enabled = true
  tags          = merge({ Name : each.key }, local.module_common_tags)

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.cache[each.key].bucket
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode = true
  }

  source {
    type            = "GITHUB"
    git_clone_depth = 1
    location        = each.value.git_repo_url
  }

}
