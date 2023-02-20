locals {
  iam_profile_name = "profile-${var.region_name}-${var.solution_fqn}-nexus"
  iam_role_name = "role-${var.region_name}-${var.solution_fqn}-nexus"
  iam_policy_name = "policy-${var.region_name}-${var.solution_fqn}-nexus"
}

resource aws_iam_instance_profile nexus {
  name = local.iam_profile_name
  role = aws_iam_role.nexus.name
  tags = merge({ Name = local.iam_profile_name }, local.module_common_tags)
}

resource aws_iam_role nexus {
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

resource aws_iam_policy nexus {
  name = local.iam_policy_name
  description = "Allow Nexus to access S3 bucket with Nexus artifacts"
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
                "${module.s3_bucket.s3_bucket_arn}"
            ]
        }
    ]
}
POLICY
}

resource aws_iam_role_policy_attachment nexus {
  policy_arn = aws_iam_policy.nexus.arn
  role = aws_iam_role.nexus.name
}