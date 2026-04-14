locals {
  namespace           = var.namespace
  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  vpc_name            = "vpc-${local.cluster_name}"
  vpc_cidr_block      = var.vpc_cidr_block
  vpc_private_subnets = var.vpc_private_subnet_cidrs
  vpc_public_subnets  = var.vpc_public_subnet_cidrs

  tags = merge({
    "${var.namespace}/cluster"       = local.cluster_name
    "${var.namespace}/vpc"           = local.vpc_name,
    "${var.namespace}/organisation"  = var.organisation
    "${var.namespace}/business_unit" = var.business_unit
    "${var.namespace}/environment"   = var.environment
    "${var.namespace}/terraform"     = "true"
  }, var.tags)
}
