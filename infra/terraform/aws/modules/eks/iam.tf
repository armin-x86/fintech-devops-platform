module "external_dns_iam_access" {
  source                  = "../iam/eks_external_dns_access"
  organisation            = var.organisation
  namespace               = var.namespace
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  tags                    = local.tags
}

module "external_secrets_iam_access" {
  source                  = "../iam/eks_external_secrets_access"
  organisation            = var.organisation
  namespace               = var.namespace
  secrets_namespace       = var.secret_namespace
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  tags                    = local.tags
}
