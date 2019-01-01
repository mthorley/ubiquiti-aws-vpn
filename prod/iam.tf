
/* role */
resource "aws_iam_role" "ec2_syslog_role" {
  name = "SIEMInstanceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

/* policy */
resource "aws_iam_role_policy" "siem_policy" {
  name        = "SIEMLogPolicy"
  role        = "${aws_iam_role.ec2_syslog_role.id}"
 
  policy = "${file("iam-CMSIEMRole.json")}"
}

resource "aws_iam_instance_profile" "siem_instance_profile" {
  name = "SIEMInstanceProfile"
  role = "${aws_iam_role.ec2_syslog_role.name}"
}  


