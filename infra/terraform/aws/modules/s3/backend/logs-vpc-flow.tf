locals {
  vpc_flow_logs_name        = "vpc-flow-logs"
  vpc_flow_logs_bucket_name = "${var.organisation}-${var.business_unit}-${local.vpc_flow_logs_name}-${var.environment}"
  vpc_flow_logs_tags = merge(local.tf_tags, {
    "${var.namespace}/application" = local.vpc_flow_logs_name
  }, var.tags)
}

resource "aws_s3_bucket" "vpc" {
  bucket = local.vpc_flow_logs_bucket_name
  tags   = local.vpc_flow_logs_tags
}

resource "aws_s3_bucket_ownership_controls" "vpc" {
  bucket = aws_s3_bucket.vpc.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "vpc" {
  bucket = aws_s3_bucket.vpc.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "vpc" {
  statement {
    sid = "Deny deleting bucket"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect  = "Deny"
    actions = ["s3:DeleteBucket"]
    resources = [
      aws_s3_bucket.vpc.arn
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
      aws_s3_bucket.vpc.arn,
      "${aws_s3_bucket.vpc.arn}/*"
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
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["${aws_s3_bucket.vpc.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [aws_s3_bucket.vpc.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
      ]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc" {
  bucket = local.vpc_flow_logs_bucket_name
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.vpc]

  rule {
    id = "intelligent-tiering"
    filter {}

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = var.access_log_expiry_days_vpc_flow_logs
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
resource "aws_s3_bucket_server_side_encryption_configuration" "vpc" {
  bucket = aws_s3_bucket.vpc.id

  rule {
    apply_server_side_encryption_by_default {
      # https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-s3-cmk-policy.html
      sse_algorithm = "AES256"
    }
  }

  depends_on = [aws_s3_bucket.vpc]
}

resource "aws_s3_bucket_policy" "vpc" {
  bucket = aws_s3_bucket.vpc.id
  policy = data.aws_iam_policy_document.vpc.json
}

resource "aws_s3_bucket_public_access_block" "vpc" {
  bucket                  = aws_s3_bucket.vpc.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_logging" "vpc" {
  bucket        = aws_s3_bucket.vpc.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "${local.vpc_flow_logs_bucket_name}/"
}
