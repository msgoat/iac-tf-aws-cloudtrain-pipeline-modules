locals {
  security_group_name = "sec-${var.region_name}-${var.solution_fqn}-keycloak"
}

resource aws_security_group keycloak {
  name = local.security_group_name
  description = "Controls access to the Nexus service"
  vpc_id = data.aws_subnet.given.vpc_id
  tags = merge({ Name : local.security_group_name }, local.module_common_tags)
}

resource aws_security_group_rule keycloak_http_in {
  type = "ingress"
  description = "Allows inbound HTTP traffic from within the VPC"
  from_port = 8080
  to_port = 8080
  protocol = "TCP"
  cidr_blocks = [ data.aws_vpc.given.cidr_block ]
  security_group_id = aws_security_group.keycloak.id
}

resource aws_security_group_rule keycloak_https_in {
  type = "ingress"
  description = "Allows inbound HTTPS traffic from within the VPC"
  from_port = 8443
  to_port = 8443
  protocol = "TCP"
  cidr_blocks = [ data.aws_vpc.given.cidr_block ]
  security_group_id = aws_security_group.keycloak.id
}

resource aws_security_group_rule keycloak_ssh_in {
  type = "ingress"
  description = "Allows inbound SSH traffic from within the VPC"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [ data.aws_vpc.given.cidr_block ]
  security_group_id = aws_security_group.keycloak.id
}

resource aws_security_group_rule keycloak_any_out {
  type = "egress"
  description = "Allow any outbound traffic"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.keycloak.id
}