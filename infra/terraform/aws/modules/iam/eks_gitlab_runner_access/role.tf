module "eks_role" {
  source                  = "../eks_service_account_role"
  namespace               = var.namespace
  app_namespace           = local.app_namespace
  app_name                = local.app_name
  service_account_name    = "${local.app_name}-*"
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.cluster_oidc_issuer_url
  role_policy_arns = [
    aws_iam_policy.gitlab_ecr.arn,
    aws_iam_policy.gitlab_s3.arn,
    aws_iam_policy.gitlab_ec2.arn,
    aws_iam_policy.gitlab_lambda.arn
  ]
  inline_policy_statements = var.inline_policy_statements
  tags                     = merge(local.tags, var.tags)
}
