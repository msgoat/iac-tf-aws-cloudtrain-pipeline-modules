locals {
  project_names    = [for p in var.projects : p.name]
  projects_by_name = zipmap(local.project_names, var.projects)
  project_infos = [for p in aws_codebuild_project.projects : {
    project_name : p.name
    project_id : p.id
    project_badge : p.badge_url
    project_cache_location : p.cache[0].location
  }]
}

resource "aws_codebuild_project" "projects" {
  for_each               = local.projects_by_name
  name                   = each.key
  description            = each.value.description
  service_role           = aws_iam_role.codebuild.arn
  badge_enabled          = true
  concurrent_build_limit = 1
  tags                   = merge({ Name : each.key }, local.module_common_tags)

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.shared.bucket}/cache/${each.key}"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode = true
    dynamic "environment_variable" {
      for_each = var.project_environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type            = "GITHUB"
    git_clone_depth = 1
    location        = each.value.git_repo_url
  }

}

