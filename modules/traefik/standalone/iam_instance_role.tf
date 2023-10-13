# iam_instance_role.tf
# Creates an instance role for the EC2 instance
locals {
  iam_profile_name = "profile-${var.region_name}-${var.solution_fqn}-traefik"
  iam_role_name = "role-${var.region_name}-${var.solution_fqn}-traefik"
  iam_policy_name = "policy-${var.region_name}-${var.solution_fqn}-traefik"
}

resource aws_iam_instance_profile traefik {
  name = local.iam_profile_name
  role = aws_iam_role.traefik.name
  tags = merge({ Name = local.iam_profile_name }, local.module_common_tags)
}

resource aws_iam_role traefik {
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

resource aws_iam_policy traefik {
  name = local.iam_policy_name
  description = "Allow Traefik access S3 bucket containing the traefik configuration"
  tags = merge({ Name : local.iam_policy_name }, local.module_common_tags)
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Describe*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${data.aws_s3_bucket.shared.arn}"
            ]
        }
    ]
}
POLICY
}

resource aws_iam_role_policy_attachment traefik {
  policy_arn = aws_iam_policy.traefik.arn
  role = aws_iam_role.traefik.name
}