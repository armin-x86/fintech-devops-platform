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

variable "cluster_name" {
  description = "The name of the eks cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The URL of the OpenID Connect Issuer that the OIDC issuer from"
  type        = string
}

variable "role_name" {
  description = "The name of the access"
  type        = string
  default     = "gitlab-runner"
}

variable "role_path" {
  description = "The path of the policy in IAM"
  type        = string
  default     = "/"
}

variable "role_description" {
  description = "The description of the policy"
  type        = string
  default     = "Gitlab Runner Access"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement
variable "inline_policy_statements" {
  description = "The roles inline policy statement"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
