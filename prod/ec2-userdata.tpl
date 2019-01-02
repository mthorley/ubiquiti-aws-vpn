#!/bin/bash
yum update -y
/usr/bin/aws configure set region ap-southeast-2

# Configure correct timezone
AWSCLOCK=/etc/sysconfig/clock
sed -i e 's/ZONE=UTC/ZONE=Australia/Melbourne/g' $AWSCLOCK
ln -sf /usr/share/zoneinfo/Australia/Melbourne /etc/localtime

# Install cloudwatch, configure region
yum install -y awslogs
AWSLOG_CONF=/etc/awslogs/awscli.conf
sed -i -e 's/region = us-east-1/region = ap-southeast-2/g' $AWSLOG_CONF
service awslogs start

# Enable UDP syslog 
cat >> /etc/rsyslog.conf<<'_END'
$ModLoad imudp
$UDPServerRun 514
_END
service syslog stop
service rsyslog restart


