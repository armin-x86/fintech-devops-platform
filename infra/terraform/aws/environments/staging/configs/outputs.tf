output "environment" {
  description = "Environment configuration"
  value       = local.environment
}

output "aws_region" {
  description = "AWS Region"
  value       = local.aws_region
}

output "namespace" {
  value = local.namespace
}

output "organisation" {
  description = "The organization name"
  value       = local.organisation
}

output "business_unit" {
  description = "The Business unit name"
  value       = local.business_unit

}

output "secrets_namespace" {
  description = "The namespace of secrets"
  value       = local.secrets_namespace
}

output "r53_zone" {
  description = "Route53 Zone"
  value       = local.r53_zone
}

output "aws_accounts" {
  description = "ID of AWS accounts"
  value       = local.aws_accounts

}

output "vpc" {
  description = "The requested VPC parameters"
  value       = local.vpc
}

output "vpn" {
  description = "The VPN configuration details"
  value       = local.vpn
}

output "default_tags" {
  description = "Default tags"
  value       = local.default_tags
}
