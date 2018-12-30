ssh -i ~/.ssh/id_ubiq_rsa sherwood@192.168.1.1 << EOF

source /opt/vyatta/etc/functions/script-template
configure

# --------------------------------------------------------------------------------
# IPSec Tunnel #1
# --------------------------------------------------------------------------------
# 1: Internet Key Exchange (IKE) Configuration

set vpn ipsec ike-group AWS lifetime '28800'
set vpn ipsec ike-group AWS proposal 1 dh-group '2'
set vpn ipsec ike-group AWS proposal 1 encryption 'aes128'
set vpn ipsec ike-group AWS proposal 1 hash 'sha1'
set vpn ipsec site-to-site peer 13.237.11.223 authentication mode 'pre-shared-secret'
set vpn ipsec site-to-site peer 13.237.11.223 authentication pre-shared-secret 'LQ.fvXBGA168TcKsCB7Zmo4hhjyJ1q8G'
set vpn ipsec site-to-site peer 13.237.11.223 description 'VPC tunnel 1'
set vpn ipsec site-to-site peer 13.237.11.223 ike-group 'AWS'
set vpn ipsec site-to-site peer 13.237.11.223 local-address '144.132.97.139'
set vpn ipsec site-to-site peer 13.237.11.223 vti bind 'vti0'
set vpn ipsec site-to-site peer 13.237.11.223 vti esp-group 'AWS'

# --------------------------------------------------------------------------------
# 2: IPSec Configuration

set vpn ipsec ipsec-interfaces interface 'eth0'
set vpn ipsec esp-group AWS compression 'disable'
set vpn ipsec esp-group AWS lifetime '3600'
set vpn ipsec esp-group AWS mode 'tunnel'
set vpn ipsec esp-group AWS pfs 'enable'
set vpn ipsec esp-group AWS proposal 1 encryption 'aes128'
set vpn ipsec esp-group AWS proposal 1 hash 'sha1'

set vpn ipsec ike-group AWS dead-peer-detection action 'restart'
set vpn ipsec ike-group AWS dead-peer-detection interval '15'
set vpn ipsec ike-group AWS dead-peer-detection timeout '30'

# --------------------------------------------------------------------------------
# 3: Tunnel Interface Configuration

set interfaces vti vti0 address '169.254.33.150/30'
set interfaces vti vti0 description 'VPC tunnel 1'
set interfaces vti vti0 mtu '1436'

# --------------------------------------------------------------------------------
# 4: Border Gateway Protocol (BGP) Configuration

set protocols bgp 65001 neighbor 169.254.33.149 remote-as '64513'
set protocols bgp 65001 neighbor 169.254.33.149 soft-reconfiguration 'inbound'
set protocols bgp 65001 neighbor 169.254.33.149 timers holdtime '30'
set protocols bgp 65001 neighbor 169.254.33.149 timers keepalive '10'

set protocols bgp 65001 network 192.168.1.0/24 

commit
save
exit
EOF


