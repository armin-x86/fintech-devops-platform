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
| [aws_iam_policy.gitlab_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gitlab_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gitlab_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gitlab_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.gitlab_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gitlab_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gitlab_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gitlab_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_business_unit"></a> [business\_unit](#input\_business\_unit) | The name of business unit | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the eks cluster | `string` | n/a | yes |
| <a name="input_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#input\_cluster\_oidc\_issuer\_url) | The URL of the OpenID Connect Issuer that the OIDC issuer from | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_inline_policy_statements"></a> [inline\_policy\_statements](#input\_inline\_policy\_statements) | The roles inline policy statement | `list(any)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for tagging | `string` | n/a | yes |
| <a name="input_organisation"></a> [organisation](#input\_organisation) | The name of organisation | `string` | n/a | yes |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | The description of the policy | `string` | `"Gitlab Runner Access"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the access | `string` | `"gitlab-runner"` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | The path of the policy in IAM | `string` | `"/"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_ecr_arn"></a> [policy\_ecr\_arn](#output\_policy\_ecr\_arn) | The policy's arn of the ecr access |
| <a name="output_policy_s3_arn"></a> [policy\_s3\_arn](#output\_policy\_s3\_arn) | The policy's arn of the s3 access |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags of the gitlab runner |
<!-- END_TF_DOCS -->
