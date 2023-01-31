locals {
  ec2_instance_name = "ec2-${var.region_name}-${var.solution_fqn}-nexus"
}

resource aws_instance nexus {
  ami = data.aws_ami.default[0].id
  associate_public_ip_address = false
  ebs_optimized = true
  hibernation = true
  iam_instance_profile = aws_iam_instance_profile.nexus.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_pair_name
  monitoring = true
  subnet_id = var.subnet_id
  tags = merge({
    Name = local.ec2_instance_name
  }, local.module_common_tags)
  volume_tags = merge({
    OwnedBy = local.ec2_instance_name
  }, local.module_common_tags)
  vpc_security_group_ids = [ aws_security_group.nexus.id ]
}