output ec2_instance_name {
  description = "Fully qualified name of the EC2 instance running Keycloak"
  value = aws_instance.keycloak.tags["Name"]
}

output ec2_instance_id {
  description = "Unique identifier of the EC2 instance running Keycloak"
  value = aws_instance.keycloak.id
}

output ec2_instance_public_ip {
  description = "Public IP address of the EC2 instance running Keycloak"
  value = aws_instance.keycloak.public_ip
}

output ec2_instance_private_ip {
  description = "Private IP address of the EC2 instance running Keycloak"
  value = aws_instance.keycloak.private_ip
}
