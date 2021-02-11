##############################################################################################
# OUTPUTS
##############################################################################################
output "ecr_registry" {
  description = "Returns Repository URL"
  value       = aws_ecr_repository.timeoff_repo.repository_url 
}