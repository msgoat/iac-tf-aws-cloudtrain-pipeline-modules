locals {
  iam_role_names = [for p in var.projects : p.name]
}

resource "aws_iam_role" "project" {
  for_each           = toset(local.iam_role_names)
  name               = "role-${var.region_name}-codebuild-${each.value}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags               = merge({ Name : "role-${var.region_name}-codebuild-${each.value}" }, local.module_common_tags)
}

resource "aws_iam_role_policy" "project" {
  for_each = toset(local.iam_role_names)
  name     = "policy-${var.region_name}-codebuild-${each.value}"
  role     = aws_iam_role.project[each.value].name
  policy   = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.cache[each.value].arn}",
        "${aws_s3_bucket.cache[each.value].arn}/*",
        "${aws_s3_bucket.shared.arn}",
        "${aws_s3_bucket.shared.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:eu-west-1:928593304691:secret:cloudtrain-codebuild-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:AccessKubernetesApi",
        "eks:DescribeCluster"
      ],
      "Resource": [
        "arn:aws:eks:eu-west-1:928593304691:cluster/eks-eu-west-1-cloudtrain-dev-cloudtrain"
      ]
    }
  ]
}
POLICY
}
