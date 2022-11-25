locals {
  eks_role_name = "role-${var.region_name}-cloudtrain-eks"
  eks_policy_name = "policy-${var.region_name}-cloudtrain-eks"
}

resource "aws_iam_role" "eks" {
  name               = local.eks_role_name
  tags = merge({ Name : local.eks_role_name }, local.module_common_tags)
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.codebuild.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// TODO: split into multiple policies
// TODO: restrict access to S3 to specific buckets
resource "aws_iam_policy" "eks" {
  name     = local.eks_policy_name
  description = "Allows CodeBuild to access AWS EKS clusters"
  tags = merge({ Name : local.eks_policy_name }, local.module_common_tags)
  policy   = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
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

resource aws_iam_role_policy_attachment eks {
  role = aws_iam_role.eks.name
  policy_arn = aws_iam_policy.eks.arn
}