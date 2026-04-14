locals {
  app_namespace = "kube-system"
  tags = {
    "${var.namespace}/application" = var.cluster_name
    "${var.namespace}/cluster"     = var.cluster_name
  }
  service_account_name = "system:serviceaccount:${local.app_namespace}:cluster-autoscaler-aws-cluster-autoscaler"
}
