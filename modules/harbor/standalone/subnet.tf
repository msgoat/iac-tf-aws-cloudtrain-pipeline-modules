// retrieves the subnet supposed to host the Harbor service
data aws_subnet given {
  id = var.ec2_subnet_id
}