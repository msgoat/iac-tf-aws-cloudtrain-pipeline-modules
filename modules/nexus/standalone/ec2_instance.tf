locals {
  ec2_instance_name = "ec2-${var.region_name}-${var.solution_fqn}-nexus"
  ec2_user_data = <<EOT
#!/bin/bash
/usr/bin/on_cloud_init.sh
EOT
}

resource aws_instance nexus {
  ami = var.ec2_ami_id != "" ? var.ec2_ami_id : data.aws_ami.default[0].id
  associate_public_ip_address = true
  ebs_optimized = true
  # hibernation = true
  iam_instance_profile = aws_iam_instance_profile.nexus.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_pair_name
  monitoring = false
  root_block_device {
    delete_on_termination = true
    encrypted = true
    volume_size = var.root_volume_size
    volume_type = "gp3"
    tags = merge({
      Name = "vol-${var.region_name}-${var.solution_fqn}-nexus-root"
      OwnedBy = local.ec2_instance_name
    }, local.module_common_tags)
  }
  ebs_block_device {
    device_name = "/dev/xvdb"
    delete_on_termination = var.delete_data_volume_on_termination
    encrypted = true
    snapshot_id = var.data_volume_snapshot_id
    volume_size = var.data_volume_size
    volume_type = "gp3"
    tags = merge({
      Name = "vol-${var.region_name}-${var.solution_fqn}-nexus-data"
      OwnedBy = local.ec2_instance_name
    }, local.module_common_tags)
  }
  subnet_id = var.subnet_id
  tags = merge({
    Name = local.ec2_instance_name
  }, local.module_common_tags)
  user_data = local.ec2_user_data
  vpc_security_group_ids = [ aws_security_group.nexus.id ]
 }