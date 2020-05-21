
resource "aws_route53_resolver_rule_association" "unifi_resolver" {
  resolver_rule_id = aws_route53_resolver_rule.fwd_rule.id
  vpc_id           = aws_vpc.usg_dev.id
}

resource "aws_route53_resolver_endpoint" "to_unifi" {
  name      = "toUnifi"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.usg_vpn_sg.id
  ]

  ip_address {
    subnet_id = aws_subnet.sn1.id
  }

  ip_address {
    subnet_id = aws_subnet.sn2.id
  }

  tags = {
    Name = var.env
  }
}

resource "aws_route53_resolver_rule" "fwd_rule" {

  domain_name          = "localdomain"
  name                 = "outboundRule"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.to_unifi.id

  target_ip {
    ip   = var.usg_ip # DNS server is unifi ip
    port = "53"
  }

  tags = {
    Name = var.env
  }
}


