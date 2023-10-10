data "aws_secretsmanager_secret" "github" {
  name = var.github_token_secret_name
}

data "aws_secretsmanager_secret_version" "github" {
  secret_id = data.aws_secretsmanager_secret.github.id
}