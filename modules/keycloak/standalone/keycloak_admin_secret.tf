locals {
  secret_name = "keycloak-${var.solution_fqn}-${random_uuid.keycloak.result}"
}

# create a SecretsManager secret to hold keycloak username and password
resource aws_secretsmanager_secret keycloak {
  name = local.secret_name
  tags = merge({ Name = local.secret_name }, local.module_common_tags)
}

locals {
  secret_value = {
    keycloak-user = random_string.admin_user.result
    keycloak-password = random_password.admin_password.result
  }
}

# attach the JSON encoded secrets values to the SecretsManager secret
resource aws_secretsmanager_secret_version keycloak {
  secret_id = aws_secretsmanager_secret.keycloak.id
  secret_string = jsonencode(local.secret_value)
}

resource random_uuid keycloak {

}