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

variable "projects" {
  description = "Metadata about AWS CodeBuild Projects to create"
  type = list(object({
    name : string
    description : string
    git_repo_url : string
  }))
}

variable "project_environment_variables" {
  description = "Global project environment variables shared among all AWS CodeBuild Projects"
  type        = map(string)
  default     = {}
}

variable "project_parameters" {
  description = "Global project parameters managed by AWS Systems Manager Parameter store shared among most AWS CodeBuild Projects; all parameters names are expected to start with CLOUDTRAIN_CODEBUILD_"
  type = list(object({
    name        = string
    description = string
    value       = string
  }))
  default = []
}

variable "github_token_secret_name" {
  description = "Name of the Secret Manager secret which holds the GitHub personal access token"
  default     = "cloudtrain-codebuild-github"
}

variable "github_token_value_name" {
  description = "Value name of the GitHub personal access token"
  default     = "msgoat_pat"
}