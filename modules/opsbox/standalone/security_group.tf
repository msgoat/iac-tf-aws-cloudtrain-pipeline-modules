locals {
  security_group_name = "sec-${var.region_name}-${var.solution_fqn}-opsbox"
}

resource aws_security_group opsbox {
  name = local.security_group_name
  description = "Controls access to the OpsBox service"
  vpc_id = data.aws_subnet.given.vpc_id
  tags = merge({ Name : local.security_group_name }, local.module_common_tags)
}

resource aws_security_group_rule opsbox_ssh_in {
  type = "ingress"
  description = "Allows inbound SSH traffic from within the VPC"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [ data.aws_vpc.given.cidr_block ]
  security_group_id = aws_security_group.opsbox.id
}

resource aws_security_group_rule opsbox_any_out {
  type = "egress"
  description = "Allow any outbound traffic"
  from_port = 0
  to_port = 65535
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.opsbox.id
}