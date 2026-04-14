locals {
  namespace = var.namespace
  vpc_name  = startswith(var.name, "vpc-") ? var.name : "vpc-${var.name}"

  tags = merge(var.tags, {
    "${local.namespace}/vpc"       = local.vpc_name,
    "${var.namespace}/vpc_cidr"    = var.cidr_block
    "${var.namespace}/application" = var.name
  })
}
