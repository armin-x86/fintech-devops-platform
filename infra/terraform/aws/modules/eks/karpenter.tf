# trivy:ignore:avd-aws-0342
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name                  = module.eks.cluster_name
  iam_policy_name               = "${module.eks.cluster_name}-krp-controller-policy"
  node_iam_role_name            = "${module.eks.cluster_name}-krp-node"
  rule_name_prefix              = "${module.eks.cluster_name}-krp"
  iam_policy_use_name_prefix    = false
  node_iam_role_use_name_prefix = false

  enable_irsa                     = true
  enable_v1_permissions           = true
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter-sa"]

  iam_role_name            = "${module.eks.cluster_name}-krp-controller"
  iam_role_use_name_prefix = false
  iam_role_description     = "Karpenter IAM role for ${module.eks.cluster_name}"

  enable_spot_termination   = true
  queue_name                = "${var.cluster_name}-karpenter"
  queue_kms_master_key_id   = module.eks.kms_key_id
  queue_managed_sse_enabled = false

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = merge(var.karpenter_node_iam_role_additional_policies, {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  })

  tags = merge(local.tags, {
    "${local.namespace}/module" = "karpenter"
  })
}
