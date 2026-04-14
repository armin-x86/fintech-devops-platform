module "vpc" {
  source               = "../vpc/simple"
  namespace            = var.namespace
  name                 = local.cluster_name
  cidr_block           = local.vpc_cidr_block
  private_subnet_cidrs = local.vpc_private_subnets
  public_subnet_cidrs  = local.vpc_public_subnets
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.cluster_name
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.cluster_name
  }
  availability_zones     = var.availability_zones
  tags                   = local.tags
  vpc_flow_log_enabled   = true
  vpc_flow_logs_bucket   = "${var.organisation}-${var.business_unit}-vpc-flow-logs-${var.environment}"
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az
  reuse_nat_ips          = var.reuse_nat_ips

  enable_vpn_gateway                 = var.enable_vpn_gateway
  propagate_private_route_tables_vgw = var.propagate_private_route_tables_vgw
  propagate_public_route_tables_vgw  = var.propagate_public_route_tables_vgw
  vpn_gateway_tags                   = var.vpn_gateway_tags
}

data "aws_region" "current" {}

module "vpc_endpoints_ecr" {
  source             = "../vpc/endpoints/ecr"
  create             = var.vpc_enable_vpce_ecr
  namespace          = var.namespace
  vpc_id             = module.vpc.vpc_id
  vpc_name           = module.vpc.vpc_name
  availability_zones = ["${data.aws_region.current.name}a"]
  tags               = local.tags
}

module "vpc_endpoints_s3" {
  source              = "../vpc/endpoints/s3"
  create              = var.vpc_enable_vpce_s3
  aws_account_id      = var.aws_account_id
  organisation        = var.organisation
  business_unit       = var.business_unit
  namespace           = var.namespace
  vpc_id              = module.vpc.vpc_id
  vpc_name            = module.vpc.vpc_name
  vpc_route_table_ids = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)
  tags                = local.tags
}
