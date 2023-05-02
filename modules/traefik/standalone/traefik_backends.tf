locals {
  backend_names = [for be in var.backends : be.name]
  ec2_instance_names = [for be in var.backends : be.ec2_instance_name]
  ec2_instance_names_by_backend = zipmap(local.backend_names, local.ec2_instance_names)
  backends_by_backend_name = zipmap(local.backend_names, var.backends)
  traefik_backends = [for be in var.backends : {
    name = be.name
    ec2_instance_name = be.ec2_instance_name
    ec2_instance_private_ip = data.aws_instance.backends[be.name].private_ip
    protocol = be.protocol
    port = be.port
  }]
  traefik_backends_by_name = zipmap(local.backend_names, local.traefik_backends)
}

data aws_instance backends {
  for_each = local.ec2_instance_names_by_backend
  instance_tags = {
    Name = each.value
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}