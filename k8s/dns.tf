resource "aws_route53_zone" "downme" {
  name = "downme.xyz"
}

resource "aws_route53_record" "searx" {
  name    = "searx.downme.xyz"
  type    = "A"
  ttl     = "300"
  zone_id = aws_route53_zone.downme.zone_id
  records = [
    scaleway_lb_ip.nginx_ip.ip_address,
  ]
}
