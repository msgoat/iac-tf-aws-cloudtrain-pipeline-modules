locals {
  iam_profile_name = "profile-${var.region_name}-${var.solution_fqn}-opsbox"
  iam_role_name = "role-${var.region_name}-${var.solution_fqn}-opsbox"
  iam_policy_name_ec2_access = "policy-${var.region_name}-${var.solution_fqn}-opsbox-ec2-access"
}

resource aws_iam_instance_profile opsbox {
  name = local.iam_profile_name
  role = aws_iam_role.opsbox.name
  tags = merge({ Name = local.iam_profile_name }, local.module_common_tags)
}

resource aws_iam_role opsbox {
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

resource aws_iam_policy opsbox_ec2_access {
  name = local.iam_policy_name_ec2_access
  description = "Allow OpsBox to access EC2 service"
  tags = merge({ Name : local.iam_policy_name_ec2_access }, local.module_common_tags)
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
}
POLICY
}

resource aws_iam_role_policy_attachment opsbox_ec2_access {
  policy_arn = aws_iam_policy.opsbox_ec2_access.arn
  role = aws_iam_role.opsbox.name
}
