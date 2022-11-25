# variables.tf
# ---------------------------------------------------------------------------
# Defines all input variable for this demo.
# ---------------------------------------------------------------------------

variable "region_name" {
  description = "The AWS region to deploy into (e.g. eu-central-1)."
  type        = string
}

variable "solution_name" {
  description = "The name of the AWS solution that owns all AWS resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current AWS solution stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the current AWS solution."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all AWS resources"
  type        = map(string)
}

variable subnet_id {
  description = "Unique identifier of the VPC subnet supposed to host the Nexus service"
  type = string
}

variable ec2_ami_id {
  description = "Unique identifier of the AMI the EC2 instance running the Nexus service"
  type = string
  default = ""
}

variable ec2_instance_type {
  description = "Instance type of the EC2 instance running the Nexus service"
  type = string
  default = "t3.medium"
}

variable ec2_key_pair_name {
  description = "Name of the SSH key pair used to access the EC2 instance running the Nexus service"
  type = string
}
