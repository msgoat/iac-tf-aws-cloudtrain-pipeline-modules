locals {
  eip_name = "eip-${var.region_name}-${var.solution_fqn}-traefik"
}

resource aws_eip traefik {
  tags = merge({ Name = local.eip_name }, local.module_common_tags)
}

resource aws_eip_association traefik {
  allocation_id = aws_eip.traefik.id
  instance_id = aws_instance.traefik.id
}