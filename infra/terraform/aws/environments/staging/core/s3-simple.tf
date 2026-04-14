locals {
  buckets = {
    cost-report = {
      policy                    = data.aws_iam_policy_document.cost_report.json
      append_environment_suffix = true
    }
    athena = {
      lifecycle_rules = [
        {
          id      = "expire-old-queries"
          enabled = true
          expiration = {
            days = 3
          }
        }
      ]
      append_environment_suffix = true
    }
    lb-access-logs = {
      policy        = data.aws_iam_policy_document.lb_access_logs.json
      sse_algorithm = "AES256"
      lifecycle_rules = [
        {
          id      = "remove-old-logs"
          enabled = true
          expiration = {
            days = 7
          }
        }
      ]
      append_environment_suffix = true
    }
  }
}

# This should exist in every AWS account
module "s3_simple" {
  source        = "../../../modules/s3/simple"
  organisation  = module.config.organisation
  business_unit = module.config.business_unit
  namespace     = module.config.namespace
  environment   = module.config.environment
  buckets       = local.buckets
  tags          = module.config.default_tags
}
