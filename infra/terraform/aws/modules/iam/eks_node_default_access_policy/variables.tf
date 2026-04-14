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
  description = "The cluster name for the policy"
  type        = string
}

variable "description" {
  description = "The description of the policy"
  type        = string
  default     = "AWS EKS Worker Node Default Access Policy"
}

variable "buckets" {
  description = "The available S3 buckets"
  type = map(object({
    policy              = optional(string)
    allow_worker_access = optional(bool)
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
