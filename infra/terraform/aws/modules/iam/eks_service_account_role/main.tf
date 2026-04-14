locals {
  tags = {
    "${var.namespace}/application" = var.app_name
    "${var.namespace}/cluster"     = var.cluster_name
  }
}
