data "aws_route53_zone" "zone" {
  name         = "${module.config.r53_zone}."
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = module.config.r53_zone
  subject_alternative_names = [
    "*.${module.config.r53_zone}",
    "*.bos.${module.config.r53_zone}"
  ]

  zone_id           = data.aws_route53_zone.zone.zone_id
  validation_method = "DNS"
  key_algorithm     = "EC_prime256v1"
  tags              = local.tags
}