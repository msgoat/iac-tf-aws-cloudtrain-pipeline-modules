data aws_route53_zone owner {
  name = var.domain_name
}

resource aws_route53_record backend {
  for_each = local.traefik_backends_by_name
  name = each.key
  type = "A"
  ttl = 300
  records = [aws_eip.traefik.public_ip]
  zone_id = data.aws_route53_zone.owner.id
}