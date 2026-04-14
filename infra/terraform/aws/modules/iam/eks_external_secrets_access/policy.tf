data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "${title(var.organisation)}ExternalSecretsReadOnlyPolicy"
    effect = "Allow"
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.secrets_namespace}/*"
    ]
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
  }
  statement {
    sid       = "${title(var.organisation)}ExternalSecretsListSecretsPolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "secretsmanager:ListSecrets",
      "secretsmanager:BatchGetSecretValue"
    ]
  }
}

resource "aws_iam_policy" "this" {
  name        = local.policy_name
  path        = var.path
  description = var.description
  policy      = data.aws_iam_policy_document.policy.json
  tags        = merge(local.tags, var.tags)
}
