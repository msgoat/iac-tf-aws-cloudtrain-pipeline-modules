# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local values used in this module
locals {
  module_common_tags = merge(var.common_tags, { TerraformModuleName = "codebuild/project" })
}

data "aws_region" "current" {
  name = var.region_name
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

output "available_zones" {
  value = data.aws_availability_zones.available_zones.names
}
