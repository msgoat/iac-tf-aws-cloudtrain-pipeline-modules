locals {
  asg_name = "asg-${var.region_name}-${var.solution_fqn}-nexus"
}

resource aws_autoscaling_group nexus {
  name = local.asg_name
  max_size = 1
  min_size = 1
  desired_capacity = 1
  vpc_zone_identifier = [ data.aws_subnet.given.id ]
  launch_template {
    id = aws_launch_template.nexus.id
    version = "$Latest"
  }
}
