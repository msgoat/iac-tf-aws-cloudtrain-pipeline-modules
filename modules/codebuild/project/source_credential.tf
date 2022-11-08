locals {
  raw_secret_value = data.aws_secretsmanager_secret_version.github.secret_string
  secret_value_map = jsondecode(local.raw_secret_value)
  github_token     = local.secret_value_map["pat"]
}

resource "aws_codebuild_source_credential" "credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = local.github_token
}
