data aws_ami default {
  count = var.ec2_ami_id == "" ? 1 : 0
  owners = [ "928593304691" ]
  filter {
    name   = "name"
    values = ["${var.ec2_ami_name_prefix}*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = [ var.ec2_ami_architecture ]
  }

  most_recent = true
}