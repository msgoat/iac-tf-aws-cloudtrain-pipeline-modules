locals {
  security_group_name = "sec-${var.region_name}-${var.solution_fqn}-harbor"
}

resource aws_security_group harbor {
  name = local.security_group_name
  description = "Controls access to the Nexus service"
  vpc_id = data.aws_subnet.given.vpc_id
  tags = merge({ Name : local.security_group_name }, local.module_common_tags)
}

resource aws_security_group_rule harbor_http_in {
  type = "ingress"
  description = "Allows inbound HTTP traffic from within the VPC"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = [ data.aws_vpc.given.cidr_block ]
  security_group_id = aws_security_group.harbor.id
}

resource aws_security_group_rule harbor_https_in {
  type = "ingress"
  description = "Allows inbound HTTPS traffic from within the VPC"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = [ data.aws_vpc.given.cidr_block ]
  security_group_id = aws_security_group.harbor.id
}

resource aws_security_group_rule harbor_ssh_in {
  type = "ingress"
  description = "Allows inbound SSH traffic from within the VPC"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [ data.aws_vpc.given.cidr_block ]
  security_group_id = aws_security_group.harbor.id
}

resource aws_security_group_rule harbor_any_out {
  type = "egress"
  description = "Allow any outbound traffic"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.harbor.id
}