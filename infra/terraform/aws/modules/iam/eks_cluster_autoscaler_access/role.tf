# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#enabling-iam-roles-for-service-accounts
module "eks_cluster_autoscaler_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-cluster-autoscaler-role"
  provider_url                  = var.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = [local.service_account_name]
  role_policy_arns              = [aws_iam_policy.policy.arn]
  number_of_role_policy_arns    = 1
  tags                          = merge(local.tags, var.tags)
}
