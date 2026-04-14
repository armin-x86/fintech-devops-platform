locals {
  s3_resources = flatten([
    for k, v in var.buckets :
    [
      "arn:aws:s3:::${var.organisation}-${var.business_unit}-${k}-${var.environment}/*",
      "arn:aws:s3:::${var.organisation}-${var.business_unit}-${k}-${var.environment}"
    ] if v.allow_worker_access == null ? true : v.allow_worker_access
  ])
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid       = "EksWorkerS3BucketAccessPolicy"
    effect    = "Allow"
    resources = local.s3_resources
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
  }
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid       = "EksWorkerEcrPullThroughAccessPolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr:CreateRepository",
      "ecr:BatchImportUpstreamImage",
      # Allows the node to create auth token
      "ecr:GetAuthorizationToken",
      # This allows the registry template to create tags
      "ecr:TagResource",
      # Grants permission to create a pull through cache rule.
      "ecr:CreatePullThroughCacheRule"
    ]
  }
}

data "aws_iam_policy_document" "ec2_policy" {
  statement {
    sid       = "EksWorkerEc2AccessPolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:CreateTags"
    ]
  }
}


data "aws_iam_policy_document" "policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.ecr_policy.json,
    data.aws_iam_policy_document.ec2_policy.json,
    length(local.s3_resources) == 0 ? "" : data.aws_iam_policy_document.s3_policy.json
  ]
}

resource "aws_iam_policy" "policy" {
  name        = "${var.cluster_name}-worker-default-access-policy"
  path        = "/"
  description = var.description
  policy      = data.aws_iam_policy_document.policy.json

  tags = merge({
    "${var.namespace}/application" = var.cluster_name
    "${var.namespace}/type"        = "worker"
  }, var.tags)
}
