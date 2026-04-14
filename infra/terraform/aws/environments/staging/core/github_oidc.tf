# GitHub Actions OIDC → AWS IAM federation.
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html
# https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws
#
# Workflow: permissions id-token: write + aws-actions/configure-aws-credentials with role-to-assume.

locals {
  github_actions_oidc_url = "https://token.actions.githubusercontent.com"
  github_actions_ecr_role_name = "github-actions-${module.config.organisation}-${module.config.business_unit}-${module.config.environment}-ecr"

  # repo:<owner>/<repo>:* (all branches, tags, environments for that repo).
  github_repository_subjects = [
    "repo:armin-x86/fintech-devops-platform:*",
    # "repo:armin-x86/other-repo:*",
  ]
}

data "tls_certificate" "github_actions" {
  url = local.github_actions_oidc_url
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = local.github_actions_oidc_url

  # Required when using aws-actions/configure-aws-credentials with OIDC.
  client_id_list = ["sts.amazonaws.com"]

  # Leaf cert thumbprint from the TLS chain (GitHub may rotate; re-apply if OIDC fails).
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]

  tags = merge(
    module.config.default_tags,
    {
      "${module.config.namespace}/purpose" = "github-actions-oidc"
    },
  )
}

data "aws_iam_policy_document" "github_actions_ecr_assume" {
  statement {
    sid     = "GitHubActionsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Any workflow run from the listed repos (all branches, tags, environments per repo).
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_repository_subjects
    }
  }
}

resource "aws_iam_role" "github_actions_ecr" {
  name                 = local.github_actions_ecr_role_name # see locals_github_actions.tf
  assume_role_policy   = data.aws_iam_policy_document.github_actions_ecr_assume.json
  max_session_duration = 3600

  tags = merge(
    module.config.default_tags,
    {
      "${module.config.namespace}/purpose" = "github-actions-ecr-push"
    },
  )
}

data "aws_iam_policy_document" "github_actions_ecr_push" {
  statement {
    sid    = "EcrGetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EcrPushFenceRepositories"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:ListImages",
      "ecr:BatchGetImage",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
    ]
    resources = [
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/fence-backend",
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/fence-frontend",
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/fence-backend/cache",
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/fence-frontend/cache",
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_ecr_push" {
  name   = "ecr-push-fence-repos"
  role   = aws_iam_role.github_actions_ecr.id
  policy = data.aws_iam_policy_document.github_actions_ecr_push.json
}
