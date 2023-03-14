output ec2_instance_name {
  description = "Fully qualified name of the EC2 instance running Sonarqube"
  value = aws_instance.sonarqube.tags["Name"]
}

output ec2_instance_id {
  description = "Unique identifier of the EC2 instance running Sonarqube"
  value = aws_instance.sonarqube.id
}

output ec2_instance_public_ip {
  description = "Public IP address of the EC2 instance running Sonarqube"
  value = aws_instance.sonarqube.public_ip
}

output ec2_instance_private_ip {
  description = "Private IP address of the EC2 instance running Sonarqube"
  value = aws_instance.sonarqube.private_ip
}
