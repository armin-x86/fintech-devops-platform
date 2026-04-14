variable "organisation" {
  description = "The name of organisation"
  type        = string
}

variable "business_unit" {
  description = "The name of business unit"
  type        = string
}

variable "namespace" {
  description = "The namespace for tagging"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "aws_account_id" {
  description = "12-digit AWS account ID where this cluster and VPC live (same as aws sts get-caller-identity)."
  type        = string
}

##########
# CLuster
##########

variable "cluster_name" {
  description = "The name of EKS Cluster - Please use eks-(eu|ap|us)-(0|1|2)"
  type        = string
}

variable "cluster_version" {
  description = "The version of EKS Cluster"
  type        = string
  default     = "1.33"
}

# If var.dataPlane_version provided, it will be used for all nodeGroups
# If not provided, var.cluster_version will affect the NodeGroup kubelet version
# If dataPlane_version defined inside the nodeGroup attributes, then it affects version for that specific nodeGroup and takes precedence to all the other
variable "dataPlane_version" {
  description = "Optional variable to define kubelet version for all node groups, in case just want to upgrade ControlPlane and DataPlane separately"
  type        = string
  default     = ""
}

variable "cluster_endpoint_public_access" {
  description = "Allow EKS Cluster to be access from pubic subnets"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Allow EKS Cluster to be access from defined CIDRs"
  type        = list(string)
  default     = []
}

variable "cluster_access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default = [
    "audit",
    # "api",
    # "authenticator",
    # "controllerManager",
    # "scheduler"
  ]
}

#########################
# Cluster Security Groups
#########################

variable "node_security_group_additional_rules" {
  description = "List of additional security policy additional rules"
  type        = map(any)
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security policy additional rules to add to the cluster"
  type        = map(any)
  default     = {}
}

#########################
# Cluster Logs
#########################

variable "cloudwatch_log_group_retention_in_days" {
  description = "The retention period for the cloudwatch log group. Possible values: 7 - 30 days"
  type        = number
  default     = 7
}

##########
# VPC
##########

variable "vpc_cidr_block" {
  description = "The name of EKS Cluster - Please use eks-(eu|ap|us)-(0|1|2)"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to place subnets"
  type        = list(string)
}

variable "vpc_private_subnet_cidrs" {
  description = "The list of CIDRs for cluster private subnets"
  type        = list(string)
}

variable "vpc_public_subnet_cidrs" {
  description = "The list of CIDRs for cluster public subnets"
  type        = list(string)
}

variable "vpc_enable_vpce_ecr" {
  description = "Enable VPC Endpoint for ECR"
  type        = bool
  default     = true
}

variable "vpc_enable_vpce_s3" {
  description = "Enable VPC Endpoint for S3"
  type        = bool
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}

variable "vpc_one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`"
  type        = bool
  default     = false
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  type        = bool
  default     = false
}

variable "propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = bool
  default     = false
}

variable "vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  type        = map(string)
  default     = {}
}

#############
# NLB
#############
variable "nlb_ingress_additional_cidrs" {
  description = "The list of CIDRs for cluster public subnets"
  type = list(object({
    description        = string
    public_cidr_blocks = string
  }))
  default = []
}

variable "nlb_ingress_with_prefix_list_ids" {
  description = "Additional prefix list ids to attached to public NLB"
  type        = list(any)
  default     = []
}

#################################################################
# Node Group
#################################################################
variable "node_group_desired_size" {
  description = "The EC2 node group desired capacity"
  default     = 0
  type        = number
}

variable "node_group_max_size" {
  description = "The EC2 node group max capacity"
  default     = 1
  type        = number
}

variable "node_group_min_size" {
  description = "The EC2 node group min capacity"
  default     = 0
  type        = number
}

variable "node_group_instance_types" {
  default     = ["t3a.large"]
  description = "The EC2 instance type to use"
  type        = list(string)
}

variable "node_group_capacity_type" {
  default     = "SPOT" # ON_DEMAND
  description = "The EC2 capacity type to use"
  type        = string
}

variable "node_group_disk_size" {
  description = "The node disk size"
  default     = 30
  type        = number
}

variable "node_group_subnets" {
  description = "The node group subnets"
  default     = []
  type        = list(string)
}

variable "node_group_iam_role_additional_policies" {
  description = "The node group's iam_role_additional_policies"
  default     = {}
  type        = map(string)
}

variable "node_managed_groups" {
  description = "EKS managed node group"
  default     = {}
  type = map(object({
    create_launch_template = optional(bool)
    desired_size           = number
    max_size               = number
    min_size               = number
    dataPlane_version      = optional(string) # Per Node Group kubelet version
    max_unavailable        = optional(number)
    instance_types         = list(string)
    # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
    # `AL2023_x86_64_STANDARD`, `CUSTOM`, `BOTTLEROCKET_ARM_64`, `BOTTLEROCKET_x86_64`
    ami_type                     = optional(string)
    capacity_type                = string
    disk_size                    = number
    subnet_ids                   = optional(list(string))
    bootstrap_env                = optional(object({}))
    kubelet_extra_args           = optional(string)
    key_name                     = optional(string)
    iam_role_additional_policies = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
    k8s_labels = optional(map(string))
    tags       = optional(map(string))
  }))
}

#################################################################
# Karpenter Related setup
#################################################################
variable "karpenter_node_iam_role_additional_policies" {
  description = "The extra IAM node role additional policies"
  default     = {}
  type        = map(string)
}

#################################################################
# External Secrets
#################################################################
variable "secret_namespace" {
  description = "The AWS Secrets Manager specific secrets with prefix such as team-platform, team-infra, team-options, team-mibu"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
