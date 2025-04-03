data "aws_route53_zone" "dns-domain-zone" {
  name         = "${var.dns-domain-name}.${var.dns-sub-domain-name}"
  private_zone = false
}

resource "aws_route53_record" "dns-domain-record" {
  zone_id = data.aws_route53_zone.dns-domain-zone.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.app_load_balancer.dns_name
    zone_id                = aws_lb.app_load_balancer.zone_id
    evaluate_target_health = true
  }
}