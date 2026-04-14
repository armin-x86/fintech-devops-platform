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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_recovery_window_in_days"></a> [default\_recovery\_window\_in\_days](#input\_default\_recovery\_window\_in\_days) | Recovery Window time | `number` | `30` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for tagging | `string` | n/a | yes |
| <a name="input_secret_entries"></a> [secret\_entries](#input\_secret\_entries) | Set of secret entries as key value objects | <pre>map(map(object({<br/>    application             = optional(string)<br/>    description             = optional(string)<br/>    recovery_window_in_days = optional(number)<br/>  })))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_entries"></a> [secret\_entries](#output\_secret\_entries) | key value pair of secret entries |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | list of secrets |
<!-- END_TF_DOCS -->
