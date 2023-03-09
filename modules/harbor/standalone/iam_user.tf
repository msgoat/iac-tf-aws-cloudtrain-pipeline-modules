locals {
  iam_user_name = "usr-${var.region_name}-${var.solution_fqn}-harbor"
}

resource aws_iam_user harbor {
  name = local.iam_user_name
  tags = local.module_common_tags
}

resource aws_iam_access_key harbor {
  user = aws_iam_user.harbor.name
}

resource aws_iam_user_policy_attachment harbor_s3_access {
  user = aws_iam_user.harbor.name
  policy_arn = aws_iam_policy.harbor.arn
}