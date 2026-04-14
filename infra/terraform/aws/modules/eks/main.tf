locals {
  vpc_id                 = module.vpc.vpc_id
  vpc_private_subnet_ids = module.vpc.vpc_private_subnet_ids
  vpc_public_subnet_ids  = module.vpc.vpc_public_subnet_ids
  additional_tags = {
    "${var.namespace}/application"                  = local.cluster_name
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "aws-node-termination-handler/managed"          = "true"
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  }
  labels = {
    "${var.namespace}/application"   = var.cluster_name
    "${var.namespace}/cluster"       = var.cluster_name
    "${var.namespace}/environment"   = var.environment
    "${var.namespace}/business_unit" = var.business_unit
  }
  node_groups_defaults = {
    desired_size      = var.node_group_desired_size
    max_size          = var.node_group_max_size
    min_size          = var.node_group_min_size
    instance_types    = var.node_group_instance_types
    capacity_type     = var.node_group_capacity_type
    disk_size         = var.node_group_disk_size
    dataPlane_version = var.dataPlane_version
    subnet_ids        = length(var.node_group_subnets) == 0 ? module.vpc.vpc_private_subnet_ids : var.node_group_subnets
    k8s_labels        = local.labels
    additional_tags   = local.additional_tags
    iam_role_additional_policies = merge(var.node_group_iam_role_additional_policies, {
      AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      AmazonEFSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      IngressManagePolicy          = aws_iam_policy.nginx_ingress_policy.arn
    })
  }
  eks_managed_node_groups = {
    for k, v in var.node_managed_groups :
    ("${var.cluster_name}-nodegroup-${k}") => {
      create_launch_template          = coalesce(v.create_launch_template, true)
      use_custom_launch_template      = coalesce(v.create_launch_template, true)
      name                            = "${var.cluster_name}-nodegroup-${k}"
      name_prefix                     = var.cluster_name
      cluster_version                 = coalesce(v.dataPlane_version, local.node_groups_defaults.dataPlane_version, var.cluster_version)
      iam_role_use_name_prefix        = false
      use_name_prefix                 = false
      launch_template_use_name_prefix = false
      desired_size                    = v.desired_size
      max_size                        = v.max_size
      min_size                        = v.min_size
      taints                          = coalesce(v.taints, [])
      labels                          = merge(try(local.node_groups_defaults.k8s_labels, {}), v.k8s_labels)
      subnet_ids                      = length(v.subnet_ids) == 0 ? local.node_groups_defaults.subnet_ids : v.subnet_ids
      instance_types                  = v.instance_types
      capacity_type                   = v.capacity_type
      ami_type                        = coalesce(v.ami_type, "BOTTLEROCKET_x86_64")
      disk_size                       = v.create_launch_template == null ? null : (v.create_launch_template ? v.disk_size : null)
      block_device_mappings = coalesce(v.ami_type, "BOTTLEROCKET_x86_64") == "BOTTLEROCKET_x86_64" ? {
        root = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 2
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
        container = {
          device_name = "/dev/xvdb"
          ebs = {
            volume_size           = v.disk_size
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
        } : {
        root = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = v.disk_size
            volume_type           = "gp3"
            delete_on_termination = true
          }
        }
      }
      metadata_options = {
        "http_endpoint" : "enabled",
        "http_put_response_hop_limit" : 2
        "http_tokens" : "required"
      }
      update_config = {
        max_unavailable = v.max_unavailable == null ? (v.desired_size > 0 ? max(floor(v.desired_size / 2), 1) : 1) : v.max_unavailable
      }
      kubelet_extra_args           = try(v.kubelet_extra_args, "")
      iam_role_additional_policies = v.iam_role_additional_policies == null ? local.node_groups_defaults.iam_role_additional_policies : merge(local.node_groups_defaults.iam_role_additional_policies, v.iam_role_additional_policies)
      tags                         = merge(try(local.node_groups_defaults.additional_tags, {}), v.tags)
    }
  }
}

# Somehow Trivy wrongly detects the avd-aws-0039 error since we have enabled the kms encryption for K8s secrets

# trivy:ignore:aws-ec2-no-public-egress-sgr
# trivy:ignore:avd-aws-0038
# trivy:ignore:avd-aws-0039
module "eks" {
  #ts:skip=AC_AWS_0465 Just skip logging for now
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                           = local.cluster_name
  cluster_version                        = local.cluster_version
  cluster_security_group_use_name_prefix = false

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  node_security_group_use_name_prefix = false
  iam_role_use_name_prefix            = false

  bootstrap_self_managed_addons = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      configuration_values = jsonencode({
        sidecars : {
          snapshotter : {
            forceEnable : false
          }
        }
      })
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    eks-node-monitoring-agent = {
      most_recent = true
    }
  }

  # We don't want to have logs at the moment because it costs too much on CloudWatch
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_class             = "INFREQUENT_ACCESS"

  vpc_id = local.vpc_id
  # We want to allow nodes to be in both public and private subnets
  subnet_ids               = concat(local.vpc_private_subnet_ids, local.vpc_public_subnet_ids)
  control_plane_subnet_ids = local.vpc_private_subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3a.large", "t3.large", "t3a.xlarge", "t3.xlarge"]
  }

  eks_managed_node_groups = local.eks_managed_node_groups

  node_security_group_tags = merge(local.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cluster_name
  })

  # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/network_connectivity.md
  node_security_group_additional_rules = merge(var.node_security_group_additional_rules, {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    cluster_to_nodes_common_ports = {
      description                   = "Cluster API to node common ports"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 10902
      type                          = "ingress"
      source_cluster_security_group = true
    }
  })

  cluster_security_group_additional_rules = merge(var.cluster_security_group_additional_rules, {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  })

  # Grants the IAM principal that creates the cluster an admin access entry. Do not repeat the same
  # principal_arn in var.cluster_access_entries (duplicate → 409 ResourceInUseException).
  enable_cluster_creator_admin_permissions = true

  access_entries = var.cluster_access_entries

  #   access_entries = {
  #     # One access entry with a policy associated
  #     developers = {
  #       kubernetes_groups = []
  #       principal_arn     = "arn:aws:iam::123456789012:role/something"
  #
  #       policy_associations = {
  #         view_only = {
  #           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #           access_scope = {
  #             namespaces = ["iss", "krx", "gitlab"]
  #             type       = "namespace"
  #           }
  #         }
  #       }
  #     }
  #   }

  tags = merge({
    "${var.namespace}/application" = local.cluster_name
  }, local.tags)
  depends_on = [module.vpc]
}
