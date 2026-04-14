locals {
  is_pod_identity = var.create_role && var.association_type == "pod-identity"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "role" {
  count              = local.is_pod_identity ? 1 : 0
  name               = "${var.cluster_name}-${var.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "attachments" {
  count      = local.is_pod_identity ? length(var.role_policy_arns) : 0
  policy_arn = var.role_policy_arns[count.index]
  role       = aws_iam_role.role[0].name
}

resource "aws_eks_pod_identity_association" "association" {
  count           = local.is_pod_identity && var.create_pod_identity_association ? 1 : 0
  cluster_name    = var.cluster_name
  namespace       = var.app_namespace
  service_account = var.service_account_name
  role_arn        = aws_iam_role.role[0].arn
  tags            = local.tags
}
