module "config" {
  source = "../../configs"
}

locals {
  namespace       = module.config.namespace
  cluster_name    = module.config.vpc.app-euw-1.name
  cluster_version = "1.35"
  tags = merge(
    module.cluster.tags,
    module.config.default_tags
  )
}
