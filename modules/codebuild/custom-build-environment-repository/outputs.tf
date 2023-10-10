output "ecr_repositories" {
  description = "Information about the created ECR repositories"
  value       = local.ecr_repositories_by_name
}
