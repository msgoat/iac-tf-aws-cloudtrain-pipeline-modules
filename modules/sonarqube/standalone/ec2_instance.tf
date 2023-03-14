locals {
  ec2_instance_name = "ec2-${var.region_name}-${var.solution_fqn}-sonarqube"
}

resource aws_instance sonarqube {
  ami = var.ec2_ami_id != "" ? var.ec2_ami_id : data.aws_ami.default[0].id
  associate_public_ip_address = true
  ebs_optimized = true
  # hibernation = true
  iam_instance_profile = aws_iam_instance_profile.sonarqube.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_pair_name
  monitoring = false
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = var.root_volume_size
    volume_type = "gp3"
    tags = merge({
      Name = "vol-${var.region_name}-${var.solution_fqn}-sonarqube-root"
      OwnedBy = local.ec2_instance_name
    }, local.module_common_tags)
  }
  subnet_id = var.ec2_subnet_id
  tags = merge({
    Name = local.ec2_instance_name
  }, local.module_common_tags)
  user_data = local.ec2_user_data
  vpc_security_group_ids = [ aws_security_group.sonarqube.id ]
 }