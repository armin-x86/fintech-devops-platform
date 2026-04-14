locals {
  ecr_lifecycle_policy       = data.aws_ecr_lifecycle_policy_document.ecr.json
  ecr_cache_lifecycle_policy = data.aws_ecr_lifecycle_policy_document.ecr_cache.json
}

data "aws_ecr_lifecycle_policy_document" "ecr" {
  rule {
    priority    = 1
    description = "Remove untagged"

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = 1
    }
    action {
      type = "expire"
    }
  }

  rule {
    priority    = 2
    description = "Remove mr-"

    selection {
      tag_status      = "tagged"
      tag_prefix_list = ["mr-"]
      count_type      = "sinceImagePushed"
      count_unit      = "days"
      count_number    = 10
    }
  }

  rule {
    priority    = 3
    description = "Remove rc-"

    selection {
      tag_status      = "tagged"
      tag_prefix_list = ["rc-"]
      count_type      = "sinceImagePushed"
      count_unit      = "days"
      count_number    = 20
    }
  }
}

data "aws_ecr_lifecycle_policy_document" "ecr_cache" {
  rule {
    priority    = 1
    description = "Remove untagged"

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = 1
    }
    action {
      type = "expire"
    }
  }

  rule {
    priority    = 2
    description = "Expire old layers"

    selection {
      tag_status       = "tagged"
      tag_pattern_list = ["*"]
      count_type       = "sinceImagePushed"
      count_unit       = "days"
      count_number     = 14
    }
  }
}

resource "aws_ecr_lifecycle_policy" "ecr" {
  for_each   = aws_ecr_repository.ecr
  repository = each.value.name
  policy     = endswith(each.value.name, "/cache") ? local.ecr_cache_lifecycle_policy : local.ecr_lifecycle_policy
}
