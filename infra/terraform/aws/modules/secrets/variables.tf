variable "namespace" {
  description = "The namespace for tagging"
  type        = string
}

variable "secret_entries" {
  description = "Set of secret entries as key value objects"
  type = map(map(object({
    application             = optional(string)
    description             = optional(string)
    recovery_window_in_days = optional(number)
  })))
}

variable "default_recovery_window_in_days" {
  description = "Recovery Window time"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
