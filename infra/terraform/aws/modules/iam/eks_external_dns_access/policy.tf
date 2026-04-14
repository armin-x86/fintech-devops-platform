data "aws_iam_policy_document" "policy" {
  statement {
    sid       = "${title(var.organisation)}ExternalDnsRoute53WritePolicy"
    effect    = "Allow"
    resources = ["arn:aws:route53:::hostedzone/*"]
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
  }
  statement {
    sid       = "${title(var.organisation)}ExternalDnsRoute53ReadPolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
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
