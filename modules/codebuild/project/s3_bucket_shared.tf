resource "aws_s3_bucket" "shared" {
  bucket = "s3-${var.region_name}-cloudtrain-codebuild-shared"
  tags   = merge({ Name = "s3-${var.region_name}-cloudtrain-codebuild-shared" }, local.module_common_tags)
}

// enable default encryption for data-at-rest with SSE-S3 encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "shared" {
  bucket = aws_s3_bucket.shared.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

// block public access to bucket
resource "aws_s3_bucket_public_access_block" "shared" {
  bucket                  = aws_s3_bucket.shared.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// add a bucket policy which denies HTTP access
resource "aws_s3_bucket_policy" "shared" {
  bucket = aws_s3_bucket.shared.id
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
          "${aws_s3_bucket.shared.arn}/*",
          "${aws_s3_bucket.shared.arn}"
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