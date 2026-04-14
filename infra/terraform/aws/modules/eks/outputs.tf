
################################################################################
# Cluster
################################################################################

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
  depends_on  = [module.eks.cluster_arn]
}

output "cluster_certificate_authority_data" {
  description = "The cluster authority_data"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The cidr of the VPC"
  value       = module.vpc.vpc_cidr
  depends_on  = [module.vpc]
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.vpc.vpc_name
  depends_on  = [module.vpc]
}

output "tags" {
  description = "A mapping of tags to assign to the resource."
  value       = local.tags
}
