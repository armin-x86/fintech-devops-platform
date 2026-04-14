data "aws_iam_policy_document" "policy" {
  statement {
    sid       = "${title(var.organisation)}ClusterAutoscalingPolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "eks:DescribeNodegroup"
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.cluster_name}-autoscaling-policy"
  path        = "/"
  description = "Cluster Autoscaling policy for cluster ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.policy.json

  tags = merge(local.tags, var.tags)
}
