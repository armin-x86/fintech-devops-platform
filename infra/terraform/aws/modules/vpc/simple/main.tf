# trivy:ignore:avd-aws-0102
# trivy:ignore:avd-aws-0105
# trivy:ignore:avd-aws-0178
module "vpc" {
  #ts:skip=AC_AWS_0369 We don't need flow logs
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name            = local.vpc_name
  cidr            = var.cidr_block
  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  create_igw             = true


  enable_vpn_gateway                 = var.enable_vpn_gateway
  propagate_private_route_tables_vgw = var.propagate_private_route_tables_vgw
  propagate_public_route_tables_vgw  = var.propagate_public_route_tables_vgw
  vpn_gateway_tags                   = var.vpn_gateway_tags


  # The VPC must have DNS hostname and DNS resolution support.
  # Otherwise, worker nodes cannot register with the cluster.
  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_flow_log             = var.vpc_flow_log_enabled
  flow_log_destination_type   = "s3"
  flow_log_destination_arn    = "arn:aws:s3:::${var.vpc_flow_logs_bucket}/${local.vpc_name}"
  flow_log_file_format        = "parquet"
  flow_log_log_format         = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
  flow_log_per_hour_partition = true
  flow_log_traffic_type       = "REJECT"
  vpc_flow_log_tags = merge({
    Name = local.vpc_name
  }, local.tags)

  public_subnet_tags = merge({
    "${var.namespace}/subnet_type" = "public"
    "${var.namespace}/vpc_cidr"    = var.cidr_block
  }, var.public_subnet_tags, local.tags)

  private_subnet_tags = merge({
    "${var.namespace}/subnet_type" = "private"
    "${var.namespace}/vpc_cidr"    = var.cidr_block
  }, var.private_subnet_tags, local.tags)

  public_route_table_tags = merge({
    "${var.namespace}/subnet_type" = "public"
    "${var.namespace}/vpc_cidr"    = var.cidr_block
  }, local.tags)

  private_route_table_tags = merge({
    "${var.namespace}/subnet_type" = "private"
    "${var.namespace}/vpc_cidr"    = var.cidr_block
  }, local.tags)

  tags = local.tags

  reuse_nat_ips       = var.reuse_nat_ips
  nat_gateway_tags    = local.tags
  external_nat_ip_ids = var.reuse_nat_ips ? aws_eip.nat[*].id : []
}

resource "aws_eip" "nat" {
  count = var.reuse_nat_ips ? 1 : 0
  tags = merge({
    Name = format(
      "${local.vpc_name}-%s",
      var.availability_zones[0],
    )
  }, local.tags)
}
