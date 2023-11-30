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
  module_common_tags = merge(var.common_tags, { TerraformModuleName = "sonarqube/standalone" })
}
