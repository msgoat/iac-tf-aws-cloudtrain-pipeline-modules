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

variable ec2_subnet_id {
  description = "Unique identifier of the VPC subnet supposed to host the Keycloak service"
  type = string
}

variable ec2_ami_id {
  description = "Unique identifier of the AMI the EC2 instance running the Keycloak service"
  type = string
}

variable ec2_ami_architecture {
  description = "Architecture of the AMI the EC2 instance running the Keycloak service should be based on, possible values are `x86_64` and `arm64`"
  type = string
}

variable ec2_instance_type {
  description = "Instance type of the EC2 instance running the Keycloak service"
  type = string
}

variable ec2_key_pair_name {
  description = "Name of the SSH key pair used to access the EC2 instance running the Keycloak service"
  type = string
}

variable root_volume_size {
  description = "Size of the Narbor root volume in GB"
  type = number
  default = 8
}

variable data_volume_size {
  description = "Size of the Keycloak data volume in GB"
  type = number
  default = 4
}

variable data_volume_snapshot_id {
  description = "Optional unique identifier of an EBS snapshot which should be used to restore the Keycloak data volume"
  type = string
  default = ""
}

variable final_snapshot_enabled {
  description = "Controls if a final snapshot should be created before the data volume and the database is deleted; default is `true`"
  type = bool
  default = true
}

variable db_subnet_ids {
  description = "Unique identifiers of the VPC subnets supposed to host the database of the Keycloak service"
  type = list(string)
}

variable db_snapshot_id {
  description = "Optional unique identifier of a previously created final snapshot the database should be restored from"
  type = string
  default = null
}

