output ec2_instance_name {
  description = "Fully qualified name of the EC2 instance running Nexus"
  value = aws_instance.harbor.tags["Name"]
}

output ec2_instance_id {
  description = "Unique identifier of the EC2 instance running Nexus"
  value = aws_instance.harbor.id
}

output ec2_instance_public_ip {
  description = "Public IP address of the EC2 instance running Nexus"
  value = aws_instance.harbor.public_ip
}

output artifacts_s3_bucket_id {
  description = "Unique identifier of the S3 bucket used as a storage backend for Nexus"
  value = module.s3_bucket.s3_bucket_id
}

output artifacts_s3_bucket_name {
  description = "Fully qualified name of the S3 bucket used as a storage backend for Nexus"
  value = module.s3_bucket.s3_bucket_name
}