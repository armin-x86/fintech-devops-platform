output "bucket_vars" {
  description = "List of ARN of the S3 bucket"
  value       = data.aws_iam_policy_document.combined
}

output "s3_bucket_ids" {
  description = "List of ARN of the S3 bucket"
  value       = [for bucket in aws_s3_bucket.this : bucket.arn]
}

output "buckets_logging" {
  description = "List of bucket policy of logging"
  value       = local.buckets_logging
}

output "buckets" {
  description = "List of bucket names"
  value       = local.buckets
}
