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

variable "buckets" {
  description = "The list of bucket names and their settings"
  type        = any
  default     = {}
}

variable "tags" {
  description = "The tags for the bucket"
  type        = any
  default     = {}
}
