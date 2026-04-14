<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 20.0 |
| <a name="module_eks_cluster_autoscaler_access"></a> [eks\_cluster\_autoscaler\_access](#module\_eks\_cluster\_autoscaler\_access) | ../iam/eks_cluster_autoscaler_access | n/a |
| <a name="module_external_dns_iam_access"></a> [external\_dns\_iam\_access](#module\_external\_dns\_iam\_access) | ../iam/eks_external_dns_access | n/a |
| <a name="module_external_secrets_iam_access"></a> [external\_secrets\_iam\_access](#module\_external\_secrets\_iam\_access) | ../iam/eks_external_secrets_access | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | terraform-aws-modules/eks/aws//modules/karpenter | ~> 20.0 |
| <a name="module_nlb_service_sg"></a> [nlb\_service\_sg](#module\_nlb\_service\_sg) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../vpc/simple | n/a |
| <a name="module_vpc_endpoints_ecr"></a> [vpc\_endpoints\_ecr](#module\_vpc\_endpoints\_ecr) | ../vpc/endpoints/ecr | n/a |
| <a name="module_vpc_endpoints_s3"></a> [vpc\_endpoints\_s3](#module\_vpc\_endpoints\_s3) | ../vpc/endpoints/s3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.alb_controller_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.nginx_ingress_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.aws_lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.nginx_ingress_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones to place subnets | `list(string)` | n/a | yes |
| <a name="input_business_unit"></a> [business\_unit](#input\_business\_unit) | The name of business unit | `string` | n/a | yes |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | The retention period for the cloudwatch log group. Possible values: 7 - 30 days | `number` | `7` | no |
| <a name="input_cluster_access_entries"></a> [cluster\_access\_entries](#input\_cluster\_access\_entries) | Map of access entries to add to the cluster | `any` | `{}` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable | `list(string)` | <pre>[<br/>  "audit"<br/>]</pre> | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Allow EKS Cluster to be access from pubic subnets | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | Allow EKS Cluster to be access from defined CIDRs | `list(string)` | `[]` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of EKS Cluster - Please use eks-(eu\|ap\|us)-(0\|1\|2) | `string` | n/a | yes |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | List of additional security policy additional rules to add to the cluster | `map(any)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | The version of EKS Cluster | `string` | `"1.33"` | no |
| <a name="input_dataPlane_version"></a> [dataPlane\_version](#input\_dataPlane\_version) | Optional variable to define kubelet version for all node groups, in case just want to upgrade ControlPlane and DataPlane separately | `string` | `""` | no |
| <a name="input_enable_vpn_gateway"></a> [enable\_vpn\_gateway](#input\_enable\_vpn\_gateway) | Should be true if you want to create a new VPN Gateway resource and attach it to the VPC | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_karpenter_node_iam_role_additional_policies"></a> [karpenter\_node\_iam\_role\_additional\_policies](#input\_karpenter\_node\_iam\_role\_additional\_policies) | The extra IAM node role additional policies | `map(string)` | `{}` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for tagging | `string` | n/a | yes |
| <a name="input_nlb_ingress_additional_cidrs"></a> [nlb\_ingress\_additional\_cidrs](#input\_nlb\_ingress\_additional\_cidrs) | The list of CIDRs for cluster public subnets | <pre>list(object({<br/>    description        = string<br/>    public_cidr_blocks = string<br/>  }))</pre> | `[]` | no |
| <a name="input_nlb_ingress_with_prefix_list_ids"></a> [nlb\_ingress\_with\_prefix\_list\_ids](#input\_nlb\_ingress\_with\_prefix\_list\_ids) | Additional prefix list ids to attached to public NLB | `list(any)` | `[]` | no |
| <a name="input_node_group_capacity_type"></a> [node\_group\_capacity\_type](#input\_node\_group\_capacity\_type) | The EC2 capacity type to use | `string` | `"SPOT"` | no |
| <a name="input_node_group_desired_size"></a> [node\_group\_desired\_size](#input\_node\_group\_desired\_size) | The EC2 node group desired capacity | `number` | `0` | no |
| <a name="input_node_group_disk_size"></a> [node\_group\_disk\_size](#input\_node\_group\_disk\_size) | The node disk size | `number` | `30` | no |
| <a name="input_node_group_iam_role_additional_policies"></a> [node\_group\_iam\_role\_additional\_policies](#input\_node\_group\_iam\_role\_additional\_policies) | The node group's iam\_role\_additional\_policies | `map(string)` | `{}` | no |
| <a name="input_node_group_instance_types"></a> [node\_group\_instance\_types](#input\_node\_group\_instance\_types) | The EC2 instance type to use | `list(string)` | <pre>[<br/>  "t3a.large"<br/>]</pre> | no |
| <a name="input_node_group_max_size"></a> [node\_group\_max\_size](#input\_node\_group\_max\_size) | The EC2 node group max capacity | `number` | `1` | no |
| <a name="input_node_group_min_size"></a> [node\_group\_min\_size](#input\_node\_group\_min\_size) | The EC2 node group min capacity | `number` | `0` | no |
| <a name="input_node_group_subnets"></a> [node\_group\_subnets](#input\_node\_group\_subnets) | The node group subnets | `list(string)` | `[]` | no |
| <a name="input_node_managed_groups"></a> [node\_managed\_groups](#input\_node\_managed\_groups) | EKS managed node group | <pre>map(object({<br/>    create_launch_template = optional(bool)<br/>    desired_size           = number<br/>    max_size               = number<br/>    min_size               = number<br/>    dataPlane_version      = optional(string) # Per Node Group kubelet version<br/>    max_unavailable        = optional(number)<br/>    instance_types         = list(string)<br/>    # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups<br/>    # `AL2023_x86_64_STANDARD`, `CUSTOM`, `BOTTLEROCKET_ARM_64`, `BOTTLEROCKET_x86_64`<br/>    ami_type                     = optional(string)<br/>    capacity_type                = string<br/>    disk_size                    = number<br/>    subnet_ids                   = optional(list(string))<br/>    bootstrap_env                = optional(object({}))<br/>    kubelet_extra_args           = optional(string)<br/>    key_name                     = optional(string)<br/>    iam_role_additional_policies = optional(map(string))<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })))<br/>    k8s_labels = optional(map(string))<br/>    tags       = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | List of additional security policy additional rules | `map(any)` | `{}` | no |
| <a name="input_organisation"></a> [organisation](#input\_organisation) | The name of organisation | `string` | n/a | yes |
| <a name="input_propagate_private_route_tables_vgw"></a> [propagate\_private\_route\_tables\_vgw](#input\_propagate\_private\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_propagate_public_route_tables_vgw"></a> [propagate\_public\_route\_tables\_vgw](#input\_propagate\_public\_route\_tables\_vgw) | Should be true if you want route table propagation | `bool` | `false` | no |
| <a name="input_reuse_nat_ips"></a> [reuse\_nat\_ips](#input\_reuse\_nat\_ips) | Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external\_nat\_ip\_ids' variable | `bool` | `true` | no |
| <a name="input_secret_namespace"></a> [secret\_namespace](#input\_secret\_namespace) | The AWS Secrets Manager specific secrets with prefix such as team-platform, team-infra, team-options, team-mibu | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The name of EKS Cluster - Please use eks-(eu\|ap\|us)-(0\|1\|2) | `string` | n/a | yes |
| <a name="input_vpc_enable_vpce_ecr"></a> [vpc\_enable\_vpce\_ecr](#input\_vpc\_enable\_vpce\_ecr) | Enable VPC Endpoint for ECR | `bool` | `true` | no |
| <a name="input_vpc_enable_vpce_s3"></a> [vpc\_enable\_vpce\_s3](#input\_vpc\_enable\_vpce\_s3) | Enable VPC Endpoint for S3 | `bool` | `true` | no |
| <a name="input_vpc_one_nat_gateway_per_az"></a> [vpc\_one\_nat\_gateway\_per\_az](#input\_vpc\_one\_nat\_gateway\_per\_az) | Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs` | `bool` | `false` | no |
| <a name="input_vpc_private_subnet_cidrs"></a> [vpc\_private\_subnet\_cidrs](#input\_vpc\_private\_subnet\_cidrs) | The list of CIDRs for cluster private subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_public_subnet_cidrs"></a> [vpc\_public\_subnet\_cidrs](#input\_vpc\_public\_subnet\_cidrs) | The list of CIDRs for cluster public subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_single_nat_gateway"></a> [vpc\_single\_nat\_gateway](#input\_vpc\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `true` | no |
| <a name="input_vpn_gateway_tags"></a> [vpn\_gateway\_tags](#input\_vpn\_gateway\_tags) | Additional tags for the VPN gateway | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | The cluster authority\_data |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_tags"></a> [tags](#output\_tags) | A mapping of tags to assign to the resource. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The cidr of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC |
<!-- END_TF_DOCS -->
