




##############################
# s3-simple-cost-report-policy
##############################
locals {
  aws_account = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "cost_report" {
  statement {
    sid    = "AWSCURExportPolicy"
    effect = "Allow"
    principals {
      identifiers = [
        "bcm-data-exports.amazonaws.com",
        "billingreports.amazonaws.com",
      ]
      type = "Service"
    }
    resources = [
      "arn:aws:s3:::${module.config.organisation}-${module.config.business_unit}-cost-report-${module.config.environment}",
      "arn:aws:s3:::${module.config.organisation}-${module.config.business_unit}-cost-report-${module.config.environment}/*",
    ]
    actions = [
      "s3:PutObject",
      "s3:GetBucketPolicy"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:aws:cur:us-east-1:${local.aws_account}:definition/*",
        "arn:aws:bcm-data-exports:us-east-1:${local.aws_account}:export/*"
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:SourceAccount"
      values   = [local.aws_account]
    }
  }
}


#################################
# s3-simple-lb-access-logs-policy
#################################
locals {
  lb_access_logs_arn = "arn:aws:s3:::${module.config.organisation}-${module.config.business_unit}-lb-access-logs-${module.config.environment}"
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html
data "aws_iam_policy_document" "lb_access_logs" {
  statement {
    sid    = "ALBWriteAccessPolicy"
    effect = "Allow"
    principals {
      identifiers = [
        # Europe (Ireland) – 156460612806 (elb-account-id)
        "arn:aws:iam::${module.config.aws_accounts.lb_account}:root"
      ]
      type = "AWS"
    }
    resources = [
      "${local.lb_access_logs_arn}/*"
    ]
    actions = [
      "s3:PutObject"
    ]
  }

  statement {
    sid    = "NLBLogDeliveryAclCheck"
    effect = "Allow"
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
    resources = [
      local.lb_access_logs_arn
    ]
    actions = [
      "s3:GetBucketAcl"
    ]
    condition {
      test     = "StringEquals"
      values   = [local.aws_account]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${local.aws_account}:*"]
      variable = "aws:SourceArn"
    }
  }

  statement {
    sid    = "NLBLogDeliveryWritePolicy"
    effect = "Allow"
    principals {
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
      type = "Service"
    }
    resources = [
      "${local.lb_access_logs_arn}/*"
    ]
    actions = [
      "s3:PutObject"
    ]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
    condition {
      test     = "StringEquals"
      values   = [local.aws_account]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${local.aws_account}:*"]
      variable = "aws:SourceArn"
    }
  }
}

