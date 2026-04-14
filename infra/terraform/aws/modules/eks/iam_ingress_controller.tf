data "aws_iam_policy_document" "nginx_ingress_controller" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInternetGateways"
    ]
  }
}

resource "aws_iam_policy" "nginx_ingress_policy" {
  name        = "${local.cluster_name}-nginx-ingress-policy"
  path        = "/"
  description = "IAM policy for NGINX Ingress Controller"
  policy      = data.aws_iam_policy_document.nginx_ingress_controller.json
  tags        = local.tags
}
