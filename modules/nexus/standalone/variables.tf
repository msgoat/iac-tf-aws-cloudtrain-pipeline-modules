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
  default = "ami-0670ec792ed269c9b" # latest x86_64 image
#  default = "ami-089d18ab589b45134" # latest arm image
}

variable ec2_ami_architecture {
  description = "Architecture of the AMI the EC2 instance running the Nexus service should be based on, possible values are `x86_64` and `arm64`"
  type = string
  default = "x86_64"
}

variable ec2_instance_type {
  description = "Instance type of the EC2 instance running the Nexus service"
  type = string
#   default = "t4g.large"
  default = "t3.large"
}

variable ec2_key_pair_name {
  description = "Name of the SSH key pair used to access the EC2 instance running the Nexus service"
  type = string
}

variable root_volume_size {
  description = "Size of the Nexus root volume in GB"
  type = number
  default = 8
}

variable data_volume_size {
  description = "Size of the Nexus data volume in GB"
  type = number
  default = 50
}

variable data_volume_snapshot_id {
  description = "Optional unique identifier of a previously created final snapshot the data volume should be restored from"
  type = string
  default = null
}

variable final_snapshot_enabled {
  description = "Controls if a final snapshot should be created before the data volume is deleted; default is `true`"
  type = bool
  default = true
}
