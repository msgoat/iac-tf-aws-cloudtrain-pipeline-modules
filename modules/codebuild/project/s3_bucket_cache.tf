resource "aws_s3_bucket" "cache" {
  for_each = toset(local.project_names)
  bucket   = "s3-${var.region_name}-codebuild-${each.value}-cache"
  tags     = merge({ Name = "s3-${var.region_name}-codebuild-${each.value}-cache" }, local.module_common_tags)
}

// enable default encryption for data-at-rest with SSE-S3 encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cache" {
  for_each = toset(local.project_names)
  bucket   = aws_s3_bucket.cache[each.value].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

// block public access to bucket
resource "aws_s3_bucket_public_access_block" "cache" {
  for_each                = toset(local.project_names)
  bucket                  = aws_s3_bucket.cache[each.value].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// add a bucket policy which denies HTTP access
resource "aws_s3_bucket_policy" "cache" {
  for_each = toset(local.project_names)
  bucket   = aws_s3_bucket.cache[each.value].id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "BUCKET-POLICY"
    Statement = [
      {
        Sid       = "EnforceTls"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.cache[each.value].arn}/*",
          "${aws_s3_bucket.cache[each.value].arn}",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
          NumericLessThan = {
            "s3:TlsVersion" : 1.2
          }
        }
      },
    ]
  })
}