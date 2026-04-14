locals {
  tags = {
    "${var.namespace}/module" = "secrets_manager"
  }
  flatten_entries = flatten([
    for group_key, group_value in var.secret_entries : [
      for entry_key, entry_value in group_value : {
        "${group_key}/${replace(entry_key, "-", "/")}" = merge(var.secret_entries, {
          application             = coalesce(entry_value.application, split("-", entry_key)[0])
          recovery_window_in_days = coalesce(entry_value.recovery_window_in_days, var.default_recovery_window_in_days)
          description             = coalesce(entry_value.description, "Secrets related to ${title(replace(entry_key, "-", "/"))}")
        })
      }
    ]
  ])
  secret_entries = merge(local.flatten_entries...)
}

data "aws_kms_key" "default" {
  key_id = "alias/aws/secretsmanager"
}

resource "aws_secretsmanager_secret" "this" {
  for_each                = local.secret_entries
  name                    = each.key
  recovery_window_in_days = each.value.recovery_window_in_days
  description             = each.value.description
  kms_key_id              = data.aws_kms_key.default.id
  tags = merge({
    "${var.namespace}/application" = each.value.application
  }, local.tags, var.tags)
}
