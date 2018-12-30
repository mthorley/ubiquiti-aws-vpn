ssh -i ~/.ssh/id_ubiq_rsa sherwood@192.168.1.1 << EOF

source /opt/vyatta/etc/functions/script-template
configure

delete vpn ipsec

delete interfaces vti vti0

delete protocols bgp 65001

commit
save
exit
EOF

