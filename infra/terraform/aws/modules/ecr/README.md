<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.87 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.87 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_pull_through_cache_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_ecr_registry_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_policy) | resource |
| [aws_ecr_repository.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_creation_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_creation_template) | resource |
| [aws_ecr_repository_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_role.pull_through_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.pull_through_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_lifecycle_policy_document.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_lifecycle_policy_document) | data source |
| [aws_ecr_lifecycle_policy_document.ecr_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_lifecycle_policy_document) | data source |
| [aws_ecr_lifecycle_policy_document.pull_through](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_lifecycle_policy_document) | data source |
| [aws_iam_policy_document.pull_through_registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pull_through_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pull_through_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecr_pull_through_access_accounts"></a> [ecr\_pull\_through\_access\_accounts](#input\_ecr\_pull\_through\_access\_accounts) | Accounts are allowed to pull images from the ECR | `list(string)` | `[]` | no |
| <a name="input_ecr_pull_through_registries"></a> [ecr\_pull\_through\_registries](#input\_ecr\_pull\_through\_registries) | List of pull through registries and ECR to pull images from | <pre>map(object({<br/>    ecr_repository_prefix : string<br/>    upstream_registry_url : string<br/>    credential_arn : optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_ecr_repos"></a> [ecr\_repos](#input\_ecr\_repos) | Set of ecr repos | <pre>map(object({<br/>    policy            = optional(string)<br/>    enable_cache      = optional(bool)<br/>    image_tag_mutable = optional(bool)<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_ecr_pull_through"></a> [enable\_ecr\_pull\_through](#input\_enable\_ecr\_pull\_through) | Enable setting up the ECR pull through | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for tagging | `string` | n/a | yes |
| <a name="input_organisation"></a> [organisation](#input\_organisation) | The name of organisation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_life_cycle_policy"></a> [life\_cycle\_policy](#output\_life\_cycle\_policy) | The life cycle policy of the registry |
<!-- END_TF_DOCS -->
