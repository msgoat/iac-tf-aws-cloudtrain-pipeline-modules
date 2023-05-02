locals {
  iam_profile_name = "profile-${var.region_name}-${var.solution_fqn}-keycloak"
  iam_role_name = "role-${var.region_name}-${var.solution_fqn}-keycloak"
  iam_policy_name = "policy-${var.region_name}-${var.solution_fqn}-keycloak"
}

resource aws_iam_instance_profile keycloak {
  name = local.iam_profile_name
  role = aws_iam_role.keycloak.name
  tags = merge({ Name = local.iam_profile_name }, local.module_common_tags)
}

resource aws_iam_role keycloak {
  name = local.iam_role_name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = merge({
    Name = local.iam_role_name
  }, local.module_common_tags)
}

resource aws_iam_policy keycloak {
  name = local.iam_policy_name
  description = "Allow Keycloak to access PostgreSQL server"
  tags = merge({ Name : local.iam_policy_name }, local.module_common_tags)
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessToPostgreSQLInstance",
            "Effect": "Allow",
            "Action": [
                "rds:Describe*",
                "rds:ListTagsForResource"
            ],
            "Resource": [
                "${module.postgresql.db_instance_id}"
            ]
        },
       {
            "Sid": "AllowAccessToKeyVaultSecret",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "${aws_secretsmanager_secret.keycloak.arn}"
        },
       {
            "Sid": "AllowAccessToPostgreSQLSecret",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "${module.postgresql.db_secret_id}"
        }
     ]
}
POLICY
}

resource aws_iam_role_policy_attachment keycloak {
  policy_arn = aws_iam_policy.keycloak.arn
  role = aws_iam_role.keycloak.name
}