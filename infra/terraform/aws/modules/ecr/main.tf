locals {
  current_region = data.aws_region.current.name
  #  current_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${split("/", data.aws_caller_identity.current.arn)[1]}"
  current_account_id = data.aws_caller_identity.current.account_id
  tags = {
    "${var.namespace}/module" = "ecr"
  }

  ecr_repos_cache = {
    for key, value in var.ecr_repos :
    "${key}/cache" => {
      policy            = value.policy
      image_tag_mutable = coalesce(value.image_tag_mutable, false)
    } if coalesce(value.enable_cache, false)
  }

  ecr_repos = merge(var.ecr_repos, local.ecr_repos_cache)
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_ecr_repository" "ecr" {
  for_each             = local.ecr_repos
  name                 = each.key
  image_tag_mutability = coalesce(each.value.image_tag_mutable, false) ? "MUTABLE" : "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge({
    "${var.namespace}/application" = split("/", each.key)[0]
  }, local.tags, var.tags)
}

resource "aws_ecr_repository_policy" "ecr" {
  for_each = {
    for k, v in local.ecr_repos : k => v
    if v.policy != null
  }
  policy     = each.value.policy
  repository = aws_ecr_repository.ecr[each.key].name
}
