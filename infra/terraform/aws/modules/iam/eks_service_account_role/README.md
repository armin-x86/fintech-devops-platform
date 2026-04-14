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
| <a name="module_eks_service_account_role"></a> [eks\_service\_account\_role](#module\_eks\_service\_account\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | ~> 5.54 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_pod_identity_association.association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the app for the IAM role | `string` | n/a | yes |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | The namespace where the service account resides | `string` | n/a | yes |
| <a name="input_association_type"></a> [association\_type](#input\_association\_type) | The type of IAM role to associate with the service account (irsa or pod-identity) | `string` | `"irsa"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name for all AWS resource names | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#input\_cluster\_oidc\_issuer\_url) | The URL of the OpenID Connect Issuer that the OIDC issuer from | `string` | `""` | no |
| <a name="input_create_pod_identity_association"></a> [create\_pod\_identity\_association](#input\_create\_pod\_identity\_association) | True to create pod identity association | `bool` | `true` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | True to create IAM role | `bool` | `true` | no |
| <a name="input_inline_policy_statements"></a> [inline\_policy\_statements](#input\_inline\_policy\_statements) | The roles inline policy statement | `list(any)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace of the system | `string` | n/a | yes |
| <a name="input_role_policy_arns"></a> [role\_policy\_arns](#input\_role\_policy\_arns) | List of ARNs of IAM policies to attach to IAM role | `list(string)` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | The name of the service account for the IAM role - it can be wildcard format like loki-* | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_namespace"></a> [app\_namespace](#output\_app\_namespace) | Application Namespace |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM role ARN |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | IAM role name |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Service account name |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags |
<!-- END_TF_DOCS -->
