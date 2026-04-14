output "security_group_arn" {
  description = "The ARN of the security group."
  value       = module.ecr_vpce_sg.security_group_arn
}

output "api_id" {
  description = "The ID of the ecr api endpoint."
  value       = var.create ? aws_vpc_endpoint.api[0].id : null
  depends_on  = [aws_vpc_endpoint.api]
}

output "dkr_id" {
  description = "The ID of the ecr dkr endpoint."
  value       = var.create ? aws_vpc_endpoint.dkr[0].id : null
  depends_on  = [aws_vpc_endpoint.dkr]
}
