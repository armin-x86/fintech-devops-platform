# Creating our R53 zone in AWS
module "r53" {
  source        = "../../../modules/r53"
  business_unit = module.config.business_unit
  environment   = module.config.environment
  namespace     = module.config.namespace
  organisation  = module.config.organisation
  zone_name     = module.config.r53_zone
}
