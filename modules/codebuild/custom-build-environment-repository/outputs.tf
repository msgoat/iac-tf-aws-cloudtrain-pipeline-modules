output "ecr_repository_arn" {
  description = "Full ARN of the repository"
  value       = aws_ecr_repository.this.arn
}

output "ecr_registry_id" {
  description = "Unique identifier of the ECR registry where the repository was created"
  value       = aws_ecr_repository.this.registry_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}