resource "aws_route53_record" "app" {
  zone_id = var.hosted_zone_id
  name    = "${var.app_name}.qa.mydomain.com"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

output "app_url" {
  value = "http://${aws_route53_record.app.name}"
}