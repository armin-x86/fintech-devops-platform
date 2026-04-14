output "s3_logs_bucket_arn" {
  value       = aws_s3_bucket.logs.arn
  description = "The ARN of the S3 bucket for S3 logs"
}

output "vpc_flow_bucket_arn" {
  value       = aws_s3_bucket.vpc.arn
  description = "The ARN of the S3 bucket for VPC flow logs"
}

output "terraform_state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket for Terraform state"
}
