locals {
  iam_profile_name = "profile-${var.region_name}-${var.solution_fqn}-harbor"
  iam_role_name = "role-${var.region_name}-${var.solution_fqn}-harbor"
  iam_policy_name = "policy-${var.region_name}-${var.solution_fqn}-harbor"
}

resource aws_iam_instance_profile harbor {
  name = local.iam_profile_name
  role = aws_iam_role.harbor.name
  tags = merge({ Name = local.iam_profile_name }, local.module_common_tags)
}

resource aws_iam_role harbor {
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

resource aws_iam_policy harbor {
  name = local.iam_policy_name
  description = "Allow Harbor to access S3 bucket"
  tags = merge({ Name : local.iam_policy_name }, local.module_common_tags)
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${module.s3_bucket.s3_bucket_arn}",
                "${module.s3_bucket.s3_bucket_arn}/*"
            ]
        }
    ]
}
POLICY
}

resource aws_iam_role_policy_attachment harbor {
  policy_arn = aws_iam_policy.harbor.arn
  role = aws_iam_role.harbor.name
}