output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.cluster.vpc_cidr_block
}
