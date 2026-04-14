
## CHICKEN EGG SITUATION: comment out the Managed node groups part for the very first run and then un comment it.
data "aws_subnets" "private_subnets_euw1" {
  tags = {
    "${local.namespace}/vpc"         = module.cluster.vpc_name
    "${local.namespace}/subnet_type" = "private"
  }
  depends_on = [module.cluster.vpc_name]
}

module "cluster" {
  source           = "../../../../modules/eks"
  organisation     = module.config.organisation
  business_unit    = module.config.business_unit
  namespace        = module.config.namespace
  environment      = module.config.environment
  secret_namespace = module.config.secrets_namespace

  aws_account_id = module.config.aws_accounts.stg

  cluster_name               = local.cluster_name
  cluster_version            = local.cluster_version
  vpc_cidr_block             = module.config.vpc.app-euw-1.cidr_block
  vpc_private_subnet_cidrs   = module.config.vpc.app-euw-1.private_subnet_cidrs
  vpc_public_subnet_cidrs    = module.config.vpc.app-euw-1.public_subnet_cidrs
  vpc_single_nat_gateway     = try(module.config.vpc.app-euw-1.single_nat_gateway, true) ? true : false
  vpc_one_nat_gateway_per_az = try(module.config.vpc.app-euw-1.single_nat_gateway, false) ? false : true
  reuse_nat_ips              = try(module.config.vpc.app-euw-1.single_nat_gateway, true) ? true : false
  availability_zones         = module.config.vpc.app-euw-1.availability_zones

  cluster_endpoint_public_access = true # In real production this is false and access is through ZTNA or bastion host
  cluster_endpoint_public_access_cidrs = concat(
    [module.config.vpn.wireguard_es.public_cidr_blocks],
    [module.config.vpn.wireguard_pl.public_cidr_blocks]
  )
  nlb_ingress_with_prefix_list_ids = local.nlb_ingress_with_prefix_list_ids

  # cluster_access_entries = {
  #   administrator = {
  #     kubernetes_groups = []
  #     # Provide the ARN of the role that you want to add to the cluster.
  #     principal_arn = "arn:aws:iam::ACOUNT_ID:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_administrator_eca763a90d2fcc89"

  #     policy_associations = {
  #       editor = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  # }

  node_managed_groups = {
    "1" = {
      subnet_ids = data.aws_subnets.private_subnets_euw1.ids

      iam_role_additional_policies = {
        EksNodeDefaultIamAccess = module.eks_node_default_iam_access.arn
      }

      iam_role_tags  = local.tags
      instance_types = ["t3a.xlarge", "t3.xlarge"]
      capacity_type  = "SPOT" # Change to ON_DEMAND for workload that requires a stable instance type
      min_size       = 3
      max_size       = 3
      desired_size   = 3
      disk_size      = 50
      tags           = local.tags
    }
  }
}
