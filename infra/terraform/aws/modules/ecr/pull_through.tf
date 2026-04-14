data "aws_iam_policy_document" "pull_through_repository" {
  statement {
    sid    = "${title(var.organisation)}EcrPullThroughCacheRepositoryPolicy"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = flatten([for account in var.ecr_pull_through_access_accounts : [
        "arn:aws:iam::${account}:role/app-*",
        "arn:aws:iam::${account}:role/eks-*",
        "arn:aws:iam::${account}:role/aws-reserved/sso.amazonaws.com/*"
        ]
      ])
    }
  }
}

data "aws_ecr_lifecycle_policy_document" "pull_through" {
  rule {
    priority    = 1
    description = "Remove untagged"

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = 1
    }
    action {
      type = "expire"
    }
  }
  rule {
    priority    = 2
    description = "Remove old images"

    selection {
      tag_status       = "tagged"
      tag_pattern_list = ["*"]
      count_type       = "sinceImagePushed"
      count_unit       = "days"
      count_number     = 30
    }
  }
}

resource "aws_ecr_pull_through_cache_rule" "this" {
  for_each              = var.enable_ecr_pull_through && var.ecr_pull_through_registries != null ? var.ecr_pull_through_registries : {}
  ecr_repository_prefix = each.value.ecr_repository_prefix
  upstream_registry_url = each.value.upstream_registry_url
  credential_arn        = try(each.value.credential_arn, "")
}

resource "aws_ecr_repository_creation_template" "this" {
  for_each          = var.enable_ecr_pull_through && var.ecr_pull_through_registries != null ? var.ecr_pull_through_registries : {}
  prefix            = each.value.ecr_repository_prefix
  applied_for       = ["PULL_THROUGH_CACHE"]
  description       = "Pull through template for ${each.key}"
  lifecycle_policy  = data.aws_ecr_lifecycle_policy_document.pull_through.json
  repository_policy = data.aws_iam_policy_document.pull_through_repository.json
  custom_role_arn   = aws_iam_role.pull_through_role.arn

  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  resource_tags = merge({
    "${var.namespace}/application" = "ecr"
  }, local.tags, var.tags)
}

# terraform import 'module.ecr.aws_ecr_pull_through_cache_rule.this['docker']' 'docker.io'

data "aws_iam_policy_document" "pull_through_role_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr:CreateRepository",
      "ecr:ReplicateImage",
      "ecr:TagResource"
    ]
  }
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:CreateGrant",
      "kms:RetireGrant",
      "kms:DescribeKey"
    ]
  }
}

resource "aws_iam_role_policy" "pull_through_role_policy" {
  name   = "${var.organisation}-ecr-pull-through-role-policy"
  role   = aws_iam_role.pull_through_role.name
  policy = data.aws_iam_policy_document.pull_through_role_policy.json
}

resource "aws_iam_role" "pull_through_role" {
  name = "${var.organisation}-ecr-pull-through-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecr.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(local.tags, var.tags)
}
