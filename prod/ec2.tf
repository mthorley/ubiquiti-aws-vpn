
data "aws_ami" "amzn_linux" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_security_group" "usg_vpn_sg" {
  name        = "usg-vpn-sg"
  description = "Allow ssh, icmp, syslog"
  vpc_id = "${aws_vpc.usg_dev.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.usg_cidr}"]
  }

  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks  = ["${var.usg_cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}"
  }
}

/*
Instantiate ec2instance with remote syslog listening
on UDP 514.
Syslog user data as per https://access.redhat.com/solutions/54363 
*/
resource "aws_instance" "syslog" {
  ami           = "${data.aws_ami.amzn_linux.id}"
  instance_type = "t2.micro"
  key_name      = "siem-kp"
  private_ip    = "172.16.0.246"
  subnet_id      = "${aws_subnet.sn1.id}"
  vpc_security_group_ids = [ "${aws_security_group.usg_vpn_sg.id}" ]

  user_data = <<-EOF
                 #!/bin/bash
                 cat >> /etc/rsyslog.conf<<'_END'
                 # Provides UDP syslog reception
                 $ModLoad imudp
                 $UDPServerRun 514
                 _END
                 service syslog stop
                 service rsyslog restart
                 EOF
  
  tags = {
    Name = "${var.env}"
  }
}

