variable "namespace" {
  description = "The namespace for tagging"
  type        = string
}

variable "create" {
  description = "True/False to create the resource"
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The name of VPC"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "private_dns_enabled" {
  description = "Enable/Disable private dns"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "The list of security group ids"
  type        = list(string)
  default     = null
}

variable "availability_zones" {
  description = "Availability zones for the endpoints"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "The tags for the resource"
  type        = any
  default     = {}
}
