locals {
  codebuild_role_name   = "role-${var.region_name}-cloudtrain-codebuild"
  codebuild_policy_name = "policy-${var.region_name}-cloudtrain-codebuild"
}

resource "aws_iam_role" "codebuild" {
  name               = local.codebuild_role_name
  tags               = merge({ Name : local.codebuild_role_name }, local.module_common_tags)
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
}

resource "aws_iam_policy" "codebuild" {
  name        = local.codebuild_policy_name
  description = "Allows CodeBuild to access AWS resources related to the solution"
  tags        = merge({ Name : local.codebuild_policy_name }, local.module_common_tags)
  policy      = <<POLICY
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
        "*"
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
        "arn:aws:eks:eu-west-1:928593304691:cluster/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:GetSessionToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:eu-west-1:928593304691:parameter/CLOUDTRAIN_CODEBUILD_*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}