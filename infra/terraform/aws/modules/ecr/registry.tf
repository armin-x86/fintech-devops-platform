# Read the following first:
# https://platformers.dev/log/2023/ecr-cross-account-pull-through-cache/
# https://github.com/aws/containers-roadmap/issues/2053

data "aws_iam_policy_document" "pull_through_registry" {
  statement {
    sid    = "${title(var.organisation)}EcrPullThroughCacheRegistryPolicy"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = var.enable_ecr_pull_through && var.ecr_pull_through_registries != null ? [
      for k, v in var.ecr_pull_through_registries :
      "arn:aws:ecr:${local.current_region}:${local.current_account_id}:repository/${v.ecr_repository_prefix}/*"
    ] : []
    actions = [
      "ecr:CreateRepository",
      "ecr:BatchImportUpstreamImage"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${local.current_account_id}:role/app-*",
        "arn:aws:iam::${local.current_account_id}:role/eks-*",
        "arn:aws:iam::${local.current_account_id}:role/aws-reserved/sso.amazonaws.com/*"
      ]
    }
  }
}

resource "aws_ecr_registry_policy" "this" {
  count  = var.enable_ecr_pull_through ? 1 : 0
  policy = data.aws_iam_policy_document.pull_through_registry.json
}
