locals {
  contains_wildcard = strcontains(var.service_account_name, "*")
  subject           = "system:serviceaccount:${var.app_namespace}:${var.service_account_name}"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#enabling-iam-roles-for-service-accounts
module "eks_service_account_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.54"
  create_role                   = var.create_role && var.association_type == "irsa"
  role_name                     = "${var.cluster_name}-${var.app_name}-role"
  role_policy_arns              = var.role_policy_arns
  inline_policy_statements      = var.inline_policy_statements
  provider_url                  = var.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = local.contains_wildcard ? [] : [local.subject]
  oidc_subjects_with_wildcards  = local.contains_wildcard ? [local.subject] : []
  tags                          = merge(local.tags, var.tags)
}
