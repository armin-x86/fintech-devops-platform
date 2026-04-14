locals {
  vpc_name = startswith(var.vpc_name, "vpc-") ? var.vpc_name : "vpc-${var.vpc_name}"
  app_name = replace(var.vpc_name, "vpc-", "")
  tags = merge({
    Name                           = "${local.vpc_name}-ep-s3"
    "${var.namespace}/application" = local.app_name
    "${var.namespace}/access"      = "s3"
  }, var.tags)
}

data "aws_caller_identity" "current" {}
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "terraform_data" "caller_matches_config_account" {
  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == var.aws_account_id
      error_message = "AWS caller account (${data.aws_caller_identity.current.account_id}) must match aws_account_id from config (${var.aws_account_id})."
    }
  }
}

# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "AllowCurrentAccountServicePrincipals"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:Get*",
      "s3:PutObject*",
      "s3:DeleteObject*",
      "s3:List*",
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${var.aws_account_id}:role/*"
      ]
    }
  }

  # Only allow this account to access internal buckets
  statement {
    sid    = "DenyAllAccessNotFromCurrentAccount"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["*"]
    resources = [
      "arn:aws:s3:::${var.organisation}-${var.business_unit}-*/*",
    ]
    condition {
      test     = "StringNotEquals"
      values   = [var.aws_account_id]
      variable = "aws:PrincipalAccount"
    }
  }

  # We allow others to get from S3 which includes public S3 data such as ECR or other container images or Linux packages
  statement {
    sid    = "AllowOthersToGetFromS3"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = ["*"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  count        = var.create ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
  policy       = data.aws_iam_policy_document.s3.json
  tags         = local.tags
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  count           = var.create ? length(var.vpc_route_table_ids) : 0
  route_table_id  = var.vpc_route_table_ids[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}
