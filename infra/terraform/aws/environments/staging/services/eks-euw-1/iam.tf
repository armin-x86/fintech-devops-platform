module "eks_node_default_iam_access" {
  source        = "../../../../modules/iam/eks_node_default_access_policy"
  environment   = module.config.environment
  cluster_name  = local.cluster_name
  tags          = module.config.default_tags
  business_unit = module.config.business_unit
  namespace     = module.config.namespace
  organisation  = module.config.organisation
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# AWS Load Balancer Controller
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
data "aws_iam_policy_document" "aws_lb_controller" {
  source_policy_documents = [
    file("${path.module}/policy-files/aws-alb-controller-iam-policy-v2.14.1.json")
  ]
}

resource "aws_iam_policy" "aws_lb_controller" {
  name        = "${local.cluster_name}-aws-alb-controller-policy"
  description = "Permissions for aws-alb-controller IRSA role"
  policy      = data.aws_iam_policy_document.aws_lb_controller.json
}

module "aws_alb_controller_irsa" {
  source                  = "../../../../modules/iam/eks_service_account_role"
  namespace               = module.config.namespace
  app_name                = "aws-alb-controller"
  app_namespace           = "kube-system"
  service_account_name    = "aws-load-balancer-controller"
  cluster_name            = local.cluster_name
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url
  role_policy_arns        = [aws_iam_policy.aws_lb_controller.arn]
}
