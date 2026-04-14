output "policy_ecr_arn" {
  description = "The policy's arn of the ecr access"
  value       = aws_iam_policy.gitlab_ecr.arn
}

output "policy_s3_arn" {
  description = "The policy's arn of the s3 access"
  value       = aws_iam_policy.gitlab_s3.arn
}

output "tags" {
  description = "The tags of the gitlab runner"
  value       = local.tags
}
