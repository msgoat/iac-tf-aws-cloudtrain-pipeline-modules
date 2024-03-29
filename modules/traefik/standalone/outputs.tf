output ec2_instance_name {
  description = "Fully qualified name of the EC2 instance running Traefik"
  value = aws_instance.traefik.tags["Name"]
}

output ec2_instance_id {
  description = "Unique identifier of the EC2 instance running Traefik"
  value = aws_instance.traefik.id
}

output ec2_instance_public_ip {
  description = "Public IP address of the EC2 instance running Traefik"
  value = aws_eip.traefik.public_ip
}

output traefik_backends_by_name {
  description = "Registered Traefik backends by name"
  value = local.traefik_backends_by_name
}
