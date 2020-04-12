
resource "aws_vpc" "usg_dev" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.env
  }
}

resource "aws_subnet" "sn1" {
  vpc_id            = aws_vpc.usg_dev.id
  cidr_block        = var.sn1_cidr
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "${var.env}-private"
  }
}

resource "aws_subnet" "sn2" {
  vpc_id            = aws_vpc.usg_dev.id
  cidr_block        = var.sn2_cidr
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "${var.env}-private"
  }
}

/*
Public subnet to host NAT gateway
*/
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.usg_dev.id
  cidr_block = var.pub_sn_cidr
  
  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.usg_dev.id

  tags = {
    Name = var.env
  }
}

resource "aws_eip" "nat" {
  vpc = true
  
  depends_on = [ aws_internet_gateway.igw ]

  tags = {
    Name = var.env
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  
  depends_on = [ aws_internet_gateway.igw ]

  tags = {
    Name = var.env
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id          = aws_vpc.usg_dev.id
  amazon_side_asn = var.aws_bgp_asn

  tags = {
    Name = var.env
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = var.usg_bgp_asn
  ip_address = var.wan_ip
  type       = "ipsec.1"

  tags = {
    Name = var.env
  }
}

resource "aws_vpn_connection" "vpn_conn" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = var.env
  }
}

/*
Add nat gateway to routetable for private subnets
*/
resource "aws_route_table" "rt" {
  vpc_id           = aws_vpc.usg_dev.id
  propagating_vgws = [ aws_vpn_gateway.vpn_gateway.id ]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.env}-custom"
  }
}

resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.sn1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.sn2.id
  route_table_id = aws_route_table.rt.id
}

/*
Add internet gateway to main route table for vpc 
*/
resource "aws_route" "r" {
  route_table_id         = aws_vpc.usg_dev.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

/*
resource "aws_vpc_endpoint" "cwlogs" {
  vpc_id            = "${aws_vpc.usg_dev.id}"
  service_name      = "com.amazonaws.ap-southeast-2.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids        = ["${aws_subnet.sn1.id}", "${aws_subnet.sn2.id}"]
  private_dns_enabled = true
}
*/

