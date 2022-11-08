resource "aws_codebuild_webhook" "projects" {
  for_each     = local.projects_by_name
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