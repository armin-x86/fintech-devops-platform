
locals {
  github_actions_ecr_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.github_actions_ecr_role_name}"

  repos = {
    "fence-backend" : {
      enable_cache = true
    }
    "fence-frontend" : {
      enable_cache = true
    }
  }

  repos_with_policy = {
    for k, v in local.repos : k => {
      policy       = data.aws_iam_policy_document.cross_account.json
      enable_cache = try(v.enable_cache, false)
    }
  }
}

# Repository policies cannot include ecr:GetAuthorizationToken (registry-wide API). Put that on IAM identity
# policies for EKS node roles / GitHub OIDC role instead. See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policy-examples.html
data "aws_iam_policy_document" "cross_account" {
  statement {
    sid    = "AllowEksInstanceToPullImage"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
    ]

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${module.config.aws_accounts.stg}:role/eks-*",
      ]
    }
  }

  # Repository policy must allow the principal; IAM alone is not enough when a policy exists.
  statement {
    sid    = "AllowGitHubActionsOidcToPush"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.github_actions_ecr_role_arn]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
    ]
  }
}

module "ecr" {
  source                  = "../../../modules/ecr"
  organisation            = module.config.organisation
  namespace               = module.config.namespace
  ecr_repos               = local.repos_with_policy
  enable_ecr_pull_through = false # We will need to enable pull through for lowering the cost of the ECR
  tags                    = module.config.default_tags
  depends_on              = [module.secrets.secret_entries]
}
