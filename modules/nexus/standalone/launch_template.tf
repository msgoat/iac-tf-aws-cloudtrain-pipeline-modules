locals {
  launch_template_name = "lt-${var.region_name}-${var.solution_fqn}-nexus"
  instance_tags = local.module_common_tags
  volume_tags = local.module_common_tags
}

resource aws_launch_template nexus {
  name = local.launch_template_name
  description = "Runs Sonatype Nexus as a standalone service"
  ebs_optimized = true
  image_id = var.ec2_ami_id != "" ? var.ec2_ami_id : data.aws_ami.default[0].id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_pair_name
  vpc_security_group_ids = [ aws_security_group.nexus.id ]
  iam_instance_profile {
    arn = aws_iam_instance_profile.nexus.arn
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = local.instance_tags
  }
  tag_specifications {
    resource_type = "volume"
    tags = local.volume_tags
  }
  tags = merge({ Name : local.launch_template_name }, local.module_common_tags)
}