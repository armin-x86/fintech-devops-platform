output "iam_role_name" {
  description = "IAM role name"
  value       = local.is_pod_identity ? aws_iam_role.role[0].name : module.eks_service_account_role.iam_role_name
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = local.is_pod_identity ? aws_iam_role.role[0].arn : module.eks_service_account_role.iam_role_arn
}

output "app_namespace" {
  description = "Application Namespace"
  value       = var.app_namespace
}

output "service_account" {
  description = "Service account name"
  value       = var.service_account_name
}

output "tags" {
  description = "The tags"
  value       = local.tags
}
