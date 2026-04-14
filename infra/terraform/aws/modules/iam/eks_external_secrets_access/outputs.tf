output "policy_id" {
  description = "The policy's ID"
  value       = aws_iam_policy.this.id
}

output "policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = aws_iam_policy.this.arn
}

output "policy_description" {
  description = "The description of the policy"
  value       = aws_iam_policy.this.description
}

output "policy_name" {
  description = "The name of the policy"
  value       = aws_iam_policy.this.name
}

output "policy_path" {
  description = "The path of the policy in IAM"
  value       = aws_iam_policy.this.path
}

output "policy" {
  description = "The policy document"
  value       = aws_iam_policy.this.policy
}

output "tags" {
  description = "The tags"
  value       = local.tags
}
