locals {
  app_namespace = "kube-system"
  app_name      = "external-dns"
  #   role_name   = "${var.cluster_name}-${local.app_name}-role"
  policy_name = "${var.cluster_name}-${local.app_name}-policy"
  tags = {
    "${var.namespace}/application" = local.app_name
    "${var.namespace}/cluster"     = var.cluster_name
  }
}
