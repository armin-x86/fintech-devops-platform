variable "organisation" {
  description = "The name of organisation"
  type        = string
}

variable "namespace" {
  description = "The namespace for tagging"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "ecr_repos" {
  description = "Set of ecr repos"
  type = map(object({
    policy            = optional(string)
    enable_cache      = optional(bool)
    image_tag_mutable = optional(bool)
  }))
  default = {}
}

variable "enable_ecr_pull_through" {
  description = "Enable setting up the ECR pull through"
  type        = bool
  default     = false
}

variable "ecr_pull_through_access_accounts" {
  description = "Accounts are allowed to pull images from the ECR"
  type        = list(string)
  default     = []
}

variable "ecr_pull_through_registries" {
  description = "List of pull through registries and ECR to pull images from"
  type = map(object({
    ecr_repository_prefix : string
    upstream_registry_url : string
    credential_arn : optional(string)
  }))
  default = null
}
