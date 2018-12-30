
resource "aws_vpc" "usg_dev" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.env}"
  }
}

resource "aws_subnet" "sn1" {
  vpc_id = "${aws_vpc.usg_dev.id}"
  cidr_block = "${var.sn1_cidr}"
  availability_zone = "ap-southeast-2a"

  tags {
    Name = "${var.env}"
  }
}

resource "aws_subnet" "sn2" {
  vpc_id = "${aws_vpc.usg_dev.id}"
  cidr_block = "${var.sn2_cidr}"
  availability_zone = "ap-southeast-2b"

  tags {
    Name = "${var.env}"
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = "${aws_vpc.usg_dev.id}"
  amazon_side_asn = "${var.aws_bgp_asn}"

  tags {
    Name = "${var.env}"
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = "${var.usg_bgp_asn}"
  ip_address = "${var.wan_ip}"
  type       = "ipsec.1"

  tags {
    Name = "${var.env}"
  }
}

resource "aws_vpn_connection" "vpn_conn" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.customer_gateway.id}"
  type                = "ipsec.1"
  static_routes_only  = false

  tags {
    Name = "${var.env}"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.usg_dev.id}"
  propagating_vgws = [ "${aws_vpn_gateway.vpn_gateway.id}" ]

  tags = {
    Name = "${var.env}"
  }
}

resource "aws_route_table_association" "rt1" {
  subnet_id      = "${aws_subnet.sn1.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_route_table_association" "rt2" {
  subnet_id      = "${aws_subnet.sn2.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

