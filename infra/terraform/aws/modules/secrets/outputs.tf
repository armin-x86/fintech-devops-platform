output "secret_entries" {
  description = "key value pair of secret entries"
  value       = local.secret_entries
}

output "secrets" {
  description = "list of secrets"
  value       = aws_secretsmanager_secret.this
}
