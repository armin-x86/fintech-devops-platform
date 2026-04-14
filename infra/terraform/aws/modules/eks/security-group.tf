locals {
  ingress_cidr_blocks = concat(
    [{
      description        = "Self Internal CIDR"
      public_cidr_blocks = var.vpc_cidr_block
    }],
    [for ip in module.vpc.vpc_nat_public_ips : {
      description        = "Self NAT Gateway Address"
      public_cidr_blocks = "${ip}/32"
    }],
    var.nlb_ingress_additional_cidrs
  )
  ingress_with_cidr_blocks = flatten([for block in local.ingress_cidr_blocks : [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = block.description
      cidr_blocks = block.public_cidr_blocks
    }
  ]])
}

module "nlb_service_sg" {
  source                       = "terraform-aws-modules/security-group/aws"
  version                      = "~> 5.0"
  name                         = "${local.cluster_name}-nlb-sg"
  use_name_prefix              = false
  description                  = "Security group for user-service with custom ports open within VPC and publicly open"
  vpc_id                       = module.vpc.vpc_id
  ingress_with_cidr_blocks     = local.ingress_with_cidr_blocks
  ingress_with_prefix_list_ids = var.nlb_ingress_with_prefix_list_ids
  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Only for VPC network"
    cidr_blocks = var.vpc_cidr_block
  }]
  egress_cidr_blocks = [var.vpc_cidr_block]
  tags               = local.tags
}
