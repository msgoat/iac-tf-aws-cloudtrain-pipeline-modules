output ec2_instance_id {
  description = "Unique identifier of the EC2 instance running Nexus"
  value = aws_instance.nexus.id
}