locals {
  vpc_name = startswith(var.vpc_name, "vpc-") ? var.vpc_name : "vpc-${var.vpc_name}"
  app_name = replace(var.vpc_name, "vpc-", "")
  tags = merge({
    "${var.namespace}/application" = local.app_name
    "${var.namespace}/access"      = "ecr"
  }, var.tags)
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    "${var.namespace}/subnet_type" = "private"
    "${var.namespace}/vpc_cidr"    = data.aws_vpc.this.cidr_block
  }
}

data "aws_subnet" "dedicate" {
  for_each          = toset(var.availability_zones)
  availability_zone = each.value
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    "${var.namespace}/subnet_type" = "private"
  }
}

data "aws_vpc_endpoint_service" "dkr" {
  service      = "ecr.dkr"
  service_type = "Interface"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
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
    resources = [
      "*"
    ]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
      ]
    }
  }
}

# trivy:ignore:avd-aws-0104
module "ecr_vpce_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  create      = var.create && var.security_group_ids == null
  name        = "${var.vpc_name}-ecr-vpce-sg"
  description = "Security group for ECR VPC Endpoint"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["https-443-tcp"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]

  tags = local.tags
}

resource "aws_vpc_endpoint" "dkr" {
  count               = var.create ? 1 : 0
  vpc_id              = data.aws_vpc.this.id
  service_name        = data.aws_vpc_endpoint_service.dkr.service_name
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.dkr.service_type
  policy              = data.aws_iam_policy_document.ecr.json
  private_dns_enabled = var.private_dns_enabled
  security_group_ids  = var.security_group_ids == null ? [module.ecr_vpce_sg.security_group_id] : var.security_group_ids
  # One EIP should be enough
  subnet_ids = length(var.availability_zones) == 0 > 0 ? data.aws_subnets.this.ids : [for subnet in data.aws_subnet.dedicate : subnet.id]
  tags = merge({
    Name                      = "${local.vpc_name}-ep-ecr-dkr"
    "${var.namespace}/access" = "ecr.dkr"
  }, local.tags)
}

data "aws_vpc_endpoint_service" "api" {
  service      = "ecr.api"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "api" {
  count               = var.create ? 1 : 0
  vpc_id              = data.aws_vpc.this.id
  service_name        = data.aws_vpc_endpoint_service.api.service_name
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.api.service_type
  policy              = data.aws_iam_policy_document.ecr.json
  private_dns_enabled = var.private_dns_enabled
  security_group_ids  = var.security_group_ids == null ? [module.ecr_vpce_sg.security_group_id] : var.security_group_ids
  # One EIP should be enough
  subnet_ids = length(var.availability_zones) == 0 ? data.aws_subnets.this.ids : [for subnet in data.aws_subnet.dedicate : subnet.id]
  tags = merge({
    Name                      = "${var.vpc_name}-ep-ecr-api"
    "${var.namespace}/access" = "ecr.api"
  }, local.tags)
}
