locals {
  buckets = {
    for k, v in var.buckets :
    "${try(v.append_organisation_prefix, true) ? "${var.organisation}-${var.business_unit}-" : ""}${k}${try(v.append_environment_suffix, true) ? "-${var.environment}" : ""}" => {
      application                = try(v.application, k)
      policy                     = try(v.policy, "")
      append_environment_suffix  = try(v.append_environment_suffix, true)
      append_organisation_prefix = try(v.append_organisation_prefix, true)
      enable_logging             = try(v.enable_logging, true)
      versioning_status          = try(v.versioning_status, "Enabled")
      lifecycle_rules            = try(jsondecode(v.lifecycle_rules), try(v.lifecycle_rules, []))
      object_ownership           = try(v.object_ownership, "BucketOwnerEnforced")
      block_public_access        = try(v.block_public_access, true)
      replication_configuration  = try(v.replication_configuration, null)
      sse_algorithm              = try(v.sse_algorithm, "aws:kms")
    }
  }

  buckets_logging = {
    for k, v in local.buckets : k => v if coalesce(v.enable_logging, true)
  }

  tags = {
    "${var.namespace}/module" = "s3"
  }
}

data "aws_kms_key" "default" {
  key_id = "alias/aws/s3"
}

resource "aws_s3_bucket" "this" {
  #ts:skip=AC_AWS_0214 versioning flag has been retired from this resource
  for_each = local.buckets
  bucket   = each.key

  tags = merge({
    "${var.namespace}/application" = each.value.application
  }, local.tags, var.tags)
}

resource "aws_s3_bucket_logging" "this" {
  for_each      = local.buckets_logging
  bucket        = each.key
  target_bucket = "${var.organisation}-${var.business_unit}-s3-access-logs-${var.environment}" # data.aws_s3_bucket.logs.id
  target_prefix = "${each.key}/"
  depends_on    = [aws_s3_bucket_policy.this]
}


resource "aws_s3_bucket_versioning" "this" {
  #ts:skip=AC_AWS_0214 We don't want every bucket to have versioning enabled
  for_each = aws_s3_bucket.this
  bucket   = each.key
  versioning_configuration {
    # Enabled, Disabled, Suspended (If the version was enabled, then only Suspended works
    status = lookup(local.buckets, each.key, { versioning_status = "Enabled" }).versioning_status
  }
  depends_on = [aws_s3_bucket_policy.this]
}

# trivy:ignore:avd-aws-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "kms" {
  for_each = {
    for k, v in aws_s3_bucket.this : k => v if local.buckets[k].sse_algorithm == "aws:kms"
  }
  bucket = each.key

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_key.default.arn
    }
  }

  depends_on = [aws_s3_bucket_policy.this]
}

# trivy:ignore:avd-aws-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "aes256" {
  for_each = {
    for k, v in aws_s3_bucket.this : k => v if local.buckets[k].sse_algorithm == "AES256"
  }
  bucket = each.key

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [aws_s3_bucket_policy.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each                = aws_s3_bucket.this
  bucket                  = each.key
  block_public_acls       = lookup(local.buckets, each.key, { block_public_access = true }).block_public_access
  block_public_policy     = lookup(local.buckets, each.key, { block_public_access = true }).block_public_access
  restrict_public_buckets = lookup(local.buckets, each.key, { block_public_access = true }).block_public_access
  ignore_public_acls      = lookup(local.buckets, each.key, { block_public_access = true }).block_public_access
  depends_on              = [aws_s3_bucket_policy.this]
}

resource "aws_s3_bucket_policy" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.key
  policy   = data.aws_iam_policy_document.combined[each.key].json
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.key
  rule {
    object_ownership = lookup(local.buckets, each.key, { object_ownership = "BucketOwnerEnforced" }).object_ownership
  }

  depends_on = [aws_s3_bucket_policy.this]
}
