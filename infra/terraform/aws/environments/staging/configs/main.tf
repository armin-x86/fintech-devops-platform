
locals {
  environment       = "staging"
  aws_region        = "eu-west-1"
  namespace         = "ateimouri.com"
  organisation      = "fence"
  business_unit     = "infra"
  secrets_namespace = "team-infra/portfolio"
  r53_zone          = "portfolio.ateimouri.com"
  aws_accounts = {
    stg = "216315649159" # Change it to your before applying
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#access-logging-bucket-permissions
    lb_account = "156460612806" # LB account in eu-west-1
  }
  vpc = {
    app-euw-1 = {
      name       = "app-euw-1"
      cidr_block = "10.100.200.0/22"
      private_subnet_cidrs = [
        "10.100.200.0/24",
        "10.100.201.0/25",
        "10.100.201.128/25"
      ]
      public_subnet_cidrs = [
        "10.100.202.0/24",
        "10.100.203.0/25",
        "10.100.203.128/25"
      ]
      availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      single_nat_gateway = false
    }
  }

  vpn = {
    wireguard_es = {
      description        = "ES WireGuard server"
      public_cidr_blocks = "51.48.65.26/32"
    },
    wireguard_pl = {
      description        = "PL WireGuard server"
      public_cidr_blocks = "57.128.225.53/32"
    }
  }

  default_tags = {
    "${local.namespace}/terraform"     = "true"
    "${local.namespace}/organisation"  = local.organisation
    "${local.namespace}/business_unit" = local.business_unit
    "${local.namespace}/environment"   = local.environment
  }
}
