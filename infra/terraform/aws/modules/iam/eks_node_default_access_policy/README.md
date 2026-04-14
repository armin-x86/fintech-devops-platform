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

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.ec2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_buckets"></a> [buckets](#input\_buckets) | The available S3 buckets | <pre>map(object({<br/>    policy              = optional(string)<br/>    allow_worker_access = optional(bool)<br/>  }))</pre> | `{}` | no |
| <a name="input_business_unit"></a> [business\_unit](#input\_business\_unit) | The name of business unit | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The cluster name for the policy | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the policy | `string` | `"AWS EKS Worker Node Default Access Policy"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for tagging | `string` | n/a | yes |
| <a name="input_organisation"></a> [organisation](#input\_organisation) | The name of organisation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN assigned by AWS to this policy |
| <a name="output_description"></a> [description](#output\_description) | The description of the policy |
| <a name="output_id"></a> [id](#output\_id) | The policy's ID |
| <a name="output_name"></a> [name](#output\_name) | The name of the policy |
| <a name="output_path"></a> [path](#output\_path) | The path of the policy in IAM |
| <a name="output_policy"></a> [policy](#output\_policy) | The policy document |
<!-- END_TF_DOCS -->
