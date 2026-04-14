module "eks_role" {
  source                  = "../eks_service_account_role"
  namespace               = var.namespace
  app_namespace           = local.app_namespace
  app_name                = local.app_name
  service_account_name    = "${local.app_name}-sa"
  cluster_name            = var.cluster_name
  role_policy_arns        = [aws_iam_policy.this.arn]
  tags                    = merge(local.tags, var.tags)
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
}
