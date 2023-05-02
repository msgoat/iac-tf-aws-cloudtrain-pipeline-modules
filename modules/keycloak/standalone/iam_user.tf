locals {
  iam_user_name = "usr-${var.region_name}-${var.solution_fqn}-keycloak"
}

resource aws_iam_user keycloak {
  name = local.iam_user_name
  tags = local.module_common_tags
}

resource aws_iam_access_key keycloak {
  user = aws_iam_user.keycloak.name
}

resource aws_iam_user_policy_attachment keycloak_s3_access {
  user = aws_iam_user.keycloak.name
  policy_arn = aws_iam_policy.keycloak.arn
}