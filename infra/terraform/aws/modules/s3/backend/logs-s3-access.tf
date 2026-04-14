
#######################################
# Create S3 Bucket for access logs
#######################################
locals {
  s3_access_logs_name        = "s3-access-logs"
  s3_access_logs_bucket_name = "${var.organisation}-${var.business_unit}-${local.s3_access_logs_name}-${var.environment}"
  s3_access_logs_tags = merge(local.tf_tags, {
    "${var.namespace}/application" = local.s3_access_logs_name
  }, var.tags)
}

resource "aws_s3_bucket" "logs" {
  bucket = local.s3_access_logs_bucket_name
  tags   = local.s3_access_logs_tags
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = local.s3_access_logs_bucket_name
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.logs]

  rule {
    id = "intelligent-tiering"
    filter {}

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = var.access_log_expiry_days_s3
    }

    status = "Enabled"
  }

  rule {
    id = "expire-noncurrent"
    filter {}

    expiration {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    status = "Enabled"
  }
}

# trivy:ignore:avd-aws-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      # We need to use AES256 for encryption since encryption with AWS-KMS (SSE-KMS) isn't supported for access loger
      # https://repost.aws/knowledge-center/s3-server-access-log-not-delivered
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json
}

data "aws_iam_policy_document" "logs" {
  statement {
    sid = "Deny deleting bucket"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect  = "Deny"
    actions = ["s3:DeleteBucket"]
    resources = [
      aws_s3_bucket.logs.arn
    ]
  }

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    actions = [
      "s3:*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }

  statement {
    sid     = "RestrictToS3ServerAccessLogs"
    effect  = "Deny"
    actions = ["s3:PutObject"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "${aws_s3_bucket.logs.arn}/*"
    ]
    condition {
      test     = "ForAllValues:StringNotEquals"
      variable = "aws:PrincipalServiceNamesList"
      values = [
        "logging.s3.amazonaws.com"
      ]
    }
  }

  statement {
    sid    = "S3ServerAccessLogsPolicy"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    resources = [
      "${aws_s3_bucket.logs.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_logging" "logs" {
  bucket        = aws_s3_bucket.logs.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "${local.s3_access_logs_bucket_name}/"
}
