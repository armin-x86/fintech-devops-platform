data "aws_iam_policy_document" "gitlab_ecr" {
  statement {
    sid       = "${title(var.organisation)}GitlabRunnersEcrPolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:CreateRepository",
      "ecr:PutImageTagMutability",
      "ecr:SetRepositoryPolicy",
      "ecr:BatchImportUpstreamImage"
    ]
  }
}

resource "aws_iam_policy" "gitlab_ecr" {
  name        = "${var.cluster_name}-${var.role_name}-ecr-policy"
  path        = var.role_path
  description = var.role_description
  policy      = data.aws_iam_policy_document.gitlab_ecr.json
  tags = merge(local.tags, var.tags, {
    "${var.namespace}/component" = "ecr"
  })
}

data "aws_iam_policy_document" "gitlab_s3" {
  statement {
    sid    = "${title(var.organisation)}GitlabRunnerS3Policy"
    effect = "Allow"
    resources = [
      "arn:aws:s3:::${var.organisation}-${var.business_unit}-gitlab-${var.environment}/*",
      "arn:aws:s3:::${var.organisation}-${var.business_unit}-gitlab-${var.environment}"
    ]
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
  }
}

resource "aws_iam_policy" "gitlab_s3" {
  name        = "${var.cluster_name}-${var.role_name}-s3-policy"
  path        = var.role_path
  description = var.role_description
  policy      = data.aws_iam_policy_document.gitlab_s3.json
  tags = merge(local.tags, var.tags, {
    "${var.namespace}/component" = "s3"
  })
}

data "aws_iam_policy_document" "gitlab_ec2" {
  statement {
    sid       = "${title(var.organisation)}GitlabRunnerEC2Policy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:DescribeInstances",
      "ec2:SendSSHPublicKey",
      "ec2:DescribeInstanceConnectEndpoints",
      "ec2-instance-connect:*"
    ]
  }
}

resource "aws_iam_policy" "gitlab_ec2" {
  name        = "${var.cluster_name}-${var.role_name}-ec2-policy"
  path        = var.role_path
  description = var.role_description
  policy      = data.aws_iam_policy_document.gitlab_ec2.json
  tags = merge(local.tags, var.tags, {
    "${var.namespace}/component" = "ec2"
  })
}

data "aws_iam_policy_document" "gitlab_lambda" {
  statement {
    sid       = "${title(var.organisation)}GitlabRunnerLambdaPolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "lambda:UpdateFunctionCode"
    ]
  }
}

resource "aws_iam_policy" "gitlab_lambda" {
  name        = "${var.cluster_name}-${var.role_name}-lambda-policy"
  path        = var.role_path
  description = var.role_description
  policy      = data.aws_iam_policy_document.gitlab_lambda.json
  tags = merge(local.tags, var.tags, {
    "${var.namespace}/component" = "lambda"
  })
}
