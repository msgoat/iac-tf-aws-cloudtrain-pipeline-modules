locals {
  iam_profile_name = "profile-${var.region_name}-${var.solution_fqn}-sonarqube"
  iam_role_name = "role-${var.region_name}-${var.solution_fqn}-sonarqube"
  iam_policy_name = "policy-${var.region_name}-${var.solution_fqn}-sonarqube"
}

resource aws_iam_instance_profile sonarqube {
  name = local.iam_profile_name
  role = aws_iam_role.sonarqube.name
  tags = merge({ Name = local.iam_profile_name }, local.module_common_tags)
}

resource aws_iam_role sonarqube {
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

resource aws_iam_policy sonarqube {
  name = local.iam_policy_name
  description = "Allow Sonarqube to access it's PostgreSQL DB"
  tags = merge({ Name : local.iam_policy_name }, local.module_common_tags)
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "rds:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${module.postgresql.db_instance_arn}"
            ]
        }
    ]
}
POLICY
}

resource aws_iam_role_policy_attachment sonarqube {
  policy_arn = aws_iam_policy.sonarqube.arn
  role = aws_iam_role.sonarqube.name
}