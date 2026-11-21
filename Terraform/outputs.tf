output "jenkins_id" {
  value = module.server.jenkins-id
}

output "jenkins_public_ip" {
  value = module.server.jenkins-puplic-ip
}

output "jenkins_security_group_id" {
  value = module.server.jenkins_security_group_id
}
output "repository_url" {
  description = "ECR Repository URL"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ECR Repository ARN"
  value       = module.ecr.repository_arn
}

output "repository_name" {
  description = "ECR Repository Name"
  value       = module.ecr.repository_name
}