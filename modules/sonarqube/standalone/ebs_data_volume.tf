resource aws_ebs_volume sonarqube_data {
  availability_zone = data.aws_subnet.given.availability_zone
  encrypted = true
  final_snapshot = var.final_snapshot_enabled
  snapshot_id = var.data_volume_snapshot_id
  size = var.data_volume_size
  type = "gp3"
  tags = merge({
    Name = "vol-${var.region_name}-${var.solution_fqn}-sonarqube-data"
    OwnedBy = local.ec2_instance_name
  }, local.module_common_tags)
}

resource aws_volume_attachment sonarqube_data {
  device_name = "/dev/xvdb"
  instance_id = aws_instance.sonarqube.id
  volume_id = aws_ebs_volume.sonarqube_data.id
}