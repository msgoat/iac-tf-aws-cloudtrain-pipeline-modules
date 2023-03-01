locals {
  iam_profile_name = "profile-${var.region_name}-${var.solution_fqn}-nexus"
  iam_role_name = "role-${var.region_name}-${var.solution_fqn}-nexus"
  iam_policy_name_s3_bucket_access = "policy-${var.region_name}-${var.solution_fqn}-nexus-s3-access"
  iam_policy_name_s3_bucket_management = "policy-${var.region_name}-${var.solution_fqn}-nexus-s3-management"
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

resource aws_iam_policy nexus_s3_bucket_access {
  name = local.iam_policy_name_s3_bucket_access
  description = "Allow Nexus to access S3 bucket with Nexus artifacts"
  tags = merge({ Name : local.iam_policy_name_s3_bucket_access }, local.module_common_tags)
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "NexusS3BlobStoreAccess",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetLifecycleConfiguration",
                "s3:PutLifecycleConfiguration",
                "s3:PutObjectTagging",
                "s3:GetObjectTagging",
                "s3:DeleteObjectTagging",
                "s3:GetBucketAcl"
            ],
            "Resource": [
                "${module.s3_bucket.s3_bucket_arn}",
                "${module.s3_bucket.s3_bucket_arn}/*"
            ]
        }
    ]
}
POLICY
}

resource aws_iam_policy nexus_s3_bucket_management {
  name = local.iam_policy_name_s3_bucket_management
  description = "Allow Nexus to create/delete S3 buckets"
  tags = merge({ Name : local.iam_policy_name_s3_bucket_management }, local.module_common_tags)
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "NexusS3BlobStoreManagement",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
POLICY
}

resource aws_iam_role_policy_attachment nexus_s3_bucket_access {
  policy_arn = aws_iam_policy.nexus_s3_bucket_access.arn
  role = aws_iam_role.nexus.name
}

resource aws_iam_role_policy_attachment nexus_s3_bucket_management {
  policy_arn = aws_iam_policy.nexus_s3_bucket_management.arn
  role = aws_iam_role.nexus.name
}