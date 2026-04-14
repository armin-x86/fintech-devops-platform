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

variable "zone_name" {
  description = "The Route53 zone name"
  type        = string
}

variable "vpc" {
  description = "Provide a list of vpc ids"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "The tags for the bucket"
  type        = any
  default     = {}
}
