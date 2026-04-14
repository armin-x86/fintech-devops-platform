module "eks_cluster_autoscaler_access" {
  source                  = "../iam/eks_cluster_autoscaler_access"
  namespace               = var.namespace
  organisation            = var.organisation
  cluster_name            = module.eks.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  tags                    = local.tags
}
