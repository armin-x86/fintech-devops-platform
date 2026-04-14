output "iam_role_arn" {
  description = "The IAM role ARN for the cluster autoscaler"
  value       = module.eks_cluster_autoscaler_role.iam_role_arn
}

output "iam_role_name" {
  description = "The IAM role name for the cluster autoscaler"
  value       = module.eks_cluster_autoscaler_role.iam_role_name
}
