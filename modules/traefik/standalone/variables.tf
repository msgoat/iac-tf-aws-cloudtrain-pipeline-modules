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
  description = "Unique identifier of the VPC subnet supposed to host the Traefik service"
  type = string
}

variable ec2_ami_id {
  description = "Unique identifier of the AMI the EC2 instance running the Traefik service"
  type = string
  default = "ami-0d6effbed616b6932" # latest arm image
}

variable ec2_ami_architecture {
  description = "Architecture of the AMI the EC2 instance running the Traefik service should be based on, possible values are `x86_64` and `arm64`"
  type = string
  default = "arm64"
}

variable ec2_instance_type {
  description = "Instance type of the EC2 instance running the Traefik service"
  type = string
  default = "t4g.micro"
}

variable ec2_key_pair_name {
  description = "Name of the SSH key pair used to access the EC2 instance running the Traefik service"
  type = string
}

variable root_volume_size {
  description = "Size of the Traefik root volume in GB"
  type = number
  default = 8
}

variable data_volume_size {
  description = "Size of the Traefik data volume in GB"
  type = number
  default = 1
}

variable data_volume_snapshot_id {
  description = "Optional unique identifier of a previously created final snapshot the data volume should be restored from"
  type = string
  default = null
}

variable final_data_volume_snapshot_enabled {
  description = "Controls if a final snapshot should be created before the data volume is deleted; default is `true`"
  type = bool
  default = true
}

variable domain_name {
  description = "Name of the super domain hosting all subdomains of the service endpoints"
  type = string
}

variable backends {
  description = "Definitions of backends Traefik should be forwarding to"
  type = list(object({
    name = string
    ec2_instance_name = string
    protocol = string
    port = number
  }))
}