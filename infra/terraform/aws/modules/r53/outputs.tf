output "route53_zone_name" {
  description = "Route53 zone name"
  value       = module.zones.route53_zone_name
}

output "route53_zone_id" {
  description = "Route53 zone id"
  value       = module.zones.route53_zone_zone_id
}

output "route53_zone_arn" {
  description = "Route53 zone arn"
  value       = module.zones.route53_zone_zone_arn
}
