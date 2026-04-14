output "life_cycle_policy" {
  description = "The life cycle policy of the registry"
  value       = local.ecr_lifecycle_policy
}
