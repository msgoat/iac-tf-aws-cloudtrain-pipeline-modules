data "aws_secretsmanager_secret" "github" {
  name = "cloudtrain-codebuild-github"
}

data "aws_secretsmanager_secret_version" "github" {
  secret_id = data.aws_secretsmanager_secret.github.id
}