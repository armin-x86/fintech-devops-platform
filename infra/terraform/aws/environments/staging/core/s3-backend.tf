module "s3_backend" {
  source                               = "../../../modules/s3/backend"
  environment                          = module.config.environment
  organisation                         = module.config.organisation
  business_unit                        = module.config.business_unit
  namespace                            = module.config.namespace
  aws_account_id                       = module.config.aws_accounts.stg
  terraform_state_admin_user_name      = "admin"
  tags                                 = module.config.default_tags
  access_log_expiry_days_s3            = 7
  access_log_expiry_days_vpc_flow_logs = 14
  bucket_name_suffix                   = "8f403v"
}
