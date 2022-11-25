data aws_ami default {
  count = var.ec2_ami_id == "" ? 1 : 0
  owners = [ "928593304691" ]
  filter {
    name   = "name"
    values = ["CloudTrain-Nexus3-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
}