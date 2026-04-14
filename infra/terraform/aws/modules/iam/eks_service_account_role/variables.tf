variable "cluster_name" {
  description = "Name for all AWS resource names"
  type        = string
}

variable "namespace" {
  description = "The namespace of the system"
  type        = string
}

variable "app_namespace" {
  description = "The namespace where the service account resides"
  type        = string
}

variable "app_name" {
  description = "The name of the app for the IAM role"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "The URL of the OpenID Connect Issuer that the OIDC issuer from"
  type        = string
  default     = ""
  validation {
    condition     = length(var.cluster_oidc_issuer_url) == 0 || (length(var.cluster_oidc_issuer_url) > 0 && var.association_type == "irsa")
    error_message = "The cluster_oidc_issuer_url only supports when association_type is irsa."
  }
}

variable "service_account_name" {
  description = "The name of the service account for the IAM role - it can be wildcard format like loki-*"
  type        = string
  validation {
    condition     = (var.association_type == "irsa") || (!strcontains(var.service_account_name, "*"))
    error_message = "The service_account_name wildcard is only supported when association_type is 'irsa'."
  }
}

variable "role_policy_arns" {
  description = "List of ARNs of IAM policies to attach to IAM role"
  type        = list(string)
}

variable "create_role" {
  description = "True to create IAM role"
  type        = bool
  default     = true
}

variable "create_pod_identity_association" {
  description = "True to create pod identity association"
  type        = bool
  default     = true
}

variable "association_type" {
  description = "The type of IAM role to associate with the service account (irsa or pod-identity)"
  type        = string
  default     = "irsa"
  validation {
    condition     = contains(["irsa", "pod-identity"], var.association_type)
    error_message = "The association_type must be one of \"irsa\" or \"pod-identity\"."
  }
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
