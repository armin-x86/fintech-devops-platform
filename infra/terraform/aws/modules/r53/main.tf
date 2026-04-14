locals {
  tags = merge({
    "${var.namespace}/application" = "route_53"
  }, var.tags)
}

module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  zones = {
    (var.zone_name) = {
      comment = "${var.zone_name} for ${var.business_unit} of ${var.organisation} (${var.environment})"
      vpc     = var.vpc
      tags    = local.tags
    }
  }

  tags = local.tags
}
