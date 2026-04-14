variable "aws_account_id" {
  description = "Expected AWS account ID for this environment (from config); must match the credentials used to run Terraform."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

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

variable "vpc_route_table_ids" {
  description = "The id of route tables"
  type        = list(string)
}

variable "tags" {
  description = "The tags for the resource"
  type        = any
  default     = {}
}
