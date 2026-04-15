locals {
  app_secrets = {
    companyNM-infra = {
      # Just a single secret to avoid leaving it empty. I real infra, we will have secrets
      # for our apps like, prometheus,grafana, semaphore and ...
      grafana = {}
    }
    ecr-pullthroughcache = {
      "gitlab.com" = {
        application = "ecr"
        description = "Pull through credentials to fetch images from gitlab.com"
      }
      "ghcr.io" = {
        application = "ecr"
        description = "Pull through credentials to fetch images from Github registry"
      }
      "docker.io" = {
        application = "ecr"
        description = "Pull through credentials to fetch images from Docker Hub"
      }
    }
  }
}

module "secrets" {
  source                          = "../../../modules/secrets"
  namespace                       = module.config.namespace
  secret_entries                  = local.app_secrets
  default_recovery_window_in_days = 7
  tags                            = module.config.default_tags
}
