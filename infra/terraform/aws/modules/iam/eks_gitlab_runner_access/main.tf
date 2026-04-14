locals {
  app_namespace = "gitlab"
  app_name      = "gitlab-runner"
  tags = {
    "${var.namespace}/application" = local.app_name
    "${var.namespace}/cluster"     = var.cluster_name
  }
}
