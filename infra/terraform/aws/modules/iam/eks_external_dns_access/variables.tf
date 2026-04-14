variable "organisation" {
  description = "The name of organisation"
  type        = string
}

variable "namespace" {
  description = "The namespace for tagging"
  type        = string
}

variable "cluster_name" {
  description = "The name of the eks cluster"
  type        = string
}

variable "path" {
  description = "The path of the policy in IAM"
  type        = string
  default     = "/"
}

variable "cluster_oidc_issuer_url" {
  description = "The URL of the OpenID Connect Issuer that the OIDC issuer from"
  type        = string
}

variable "description" {
  description = "The description of the policy"
  type        = string
  default     = "K8s External DNS Access"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
