output "id" {
  description = "ID of the S3 endpoint."
  value       = var.create ? aws_vpc_endpoint.s3[0].id : null
}
