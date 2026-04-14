#
# We utilise the AWS managed prefix list rather then security group rules
# https://docs.aws.amazon.com/vpc/latest/userguide/managed-prefix-lists.html
# PLEASE NOTE:
#  - This does not reduce the number of security group rules
#  - You can view the prefix list in VPC page

locals {
  nlb_ip_groups = merge(
    {
      vpn = [for key, value in module.config.vpn : value],
    }
  )
  # re-organise the list for prefix list
  nlb_prefix_list_entries = {
    for group, items in local.nlb_ip_groups : group => flatten([
      for item in items : [ # supports public_cidr_blocks in either string or list
        for cidr in try(split(",", item.public_cidr_blocks), item.public_cidr_blocks) : {
          cidr        = trimspace(cidr)
          description = item.description
        }
      ]
    ])
  }
  nlb_ingress_with_prefix_list_ids = [
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      description     = "HTTPS Access for accepted public IPs"
      prefix_list_ids = join(",", [for pl in aws_ec2_managed_prefix_list.nlb : pl.id])
  }]
}

resource "aws_ec2_managed_prefix_list" "nlb" {
  for_each       = local.nlb_ip_groups
  name           = "${module.config.r53_zone}.${local.cluster_name}.${each.key}"
  address_family = "IPv4"
  max_entries    = length(local.nlb_prefix_list_entries[each.key])

  dynamic "entry" {
    for_each = local.nlb_prefix_list_entries[each.key]
    content {
      cidr        = entry.value.cidr
      description = entry.value.description
    }
  }

  tags = module.cluster.tags
}
