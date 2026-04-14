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
| <a name="module_eks_role"></a> [eks\_role](#module\_eks\_role) | ../eks_service_account_role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the eks cluster | `string` | `"eks-europe-0"` | no |
| <a name="input_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#input\_cluster\_oidc\_issuer\_url) | The URL of the OpenID Connect Issuer that the OIDC issuer from | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the policy | `string` | `"K8s External Secrets Access"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for tagging | `string` | `"company.io"` | no |
| <a name="input_organisation"></a> [organisation](#input\_organisation) | The name of organisation | `string` | `"company"` | no |
| <a name="input_path"></a> [path](#input\_path) | The path of the policy in IAM | `string` | `"/"` | no |
| <a name="input_secrets_namespace"></a> [secrets\_namespace](#input\_secrets\_namespace) | The namespace of the secrets such as team-platform | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy"></a> [policy](#output\_policy) | The policy document |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | The ARN assigned by AWS to this policy |
| <a name="output_policy_description"></a> [policy\_description](#output\_policy\_description) | The description of the policy |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | The policy's ID |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | The name of the policy |
| <a name="output_policy_path"></a> [policy\_path](#output\_policy\_path) | The path of the policy in IAM |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags |
<!-- END_TF_DOCS -->
