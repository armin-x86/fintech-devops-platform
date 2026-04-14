
output "github_actions_oidc_provider_arn" {
  description = "ARN of the IAM OIDC identity provider for GitHub Actions (token.actions.githubusercontent.com)."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "github_actions_oidc_provider_url" {
  description = "Issuer URL of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github_actions.url
}

output "github_actions_ecr_role_arn" {
  description = "IAM role for GitHub Actions OIDC (configure-aws-credentials role-to-assume). Allows push to fence-* ECR repos."
  value       = aws_iam_role.github_actions_ecr.arn
}

output "s3_backend_terraform_state_bucket_arn" {
  description = "The ARN of the S3 bucket for Terraform state"
  value       = module.s3_backend.terraform_state_bucket_arn
}
