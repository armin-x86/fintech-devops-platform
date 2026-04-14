locals {
  tf_bucket_name = "${var.organisation}-${var.business_unit}-terraform-${var.environment}${var.bucket_name_suffix != "" ? "-${var.bucket_name_suffix}" : ""}"

  tf_tags = merge({
    "${var.namespace}/module" = "backend"
  }, var.tags)
}


#######################################
# Create S3 Bucket for Terraform states
#######################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.tf_bucket_name
  tags   = local.tf_tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Enable versioning so we can see the full revision history of our state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.terraform_state]

  rule {
    id = "intelligent-tiering"
    filter {}

    transition {
      storage_class = "INTELLIGENT_TIERING"
      days          = 0
    }

    status = "Enabled"
  }

  rule {
    id = "expire-noncurrent-version"
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }

    noncurrent_version_expiration {
      noncurrent_days           = 1
      newer_noncurrent_versions = 1
    }

    expiration {
      expired_object_delete_marker = true
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = data.aws_kms_key.default.id
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state.json
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_logging" "terraform_state" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "${local.tf_bucket_name}/"
}

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid = "Deny deleting bucket"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    effect  = "Deny"
    actions = ["s3:DeleteBucket"]
    resources = [
      aws_s3_bucket.terraform_state.arn
    ]
  }

  statement {
    sid    = "${title(var.organisation)}TerraformReadWriteAccessPolicy"
    effect = "Deny"
    actions = [
      "s3:GetObject",
      "s3:Put*",
      "s3:Delete*"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_administrator_*",
        "arn:aws:iam::${var.aws_account_id}:root",
        "arn:aws:iam::${var.aws_account_id}:user/${var.terraform_state_admin_user_name}"
      ]
    }
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
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}
