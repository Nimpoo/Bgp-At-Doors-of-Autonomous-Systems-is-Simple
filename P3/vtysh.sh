# Route Reflector

vtysh << EOF
configure terminal
no ipv6 forwarding
interface eth0
ip address 10.1.1.1/30
interface eth1
ip address 10.1.1.5/30
interface eth2
ip address 10.1.1.9/30
interface lo
ip address 1.1.1.1/32
router bgp 1
neighbor ibgp peer-group
neighbor ibgp remote-as 1
neighbor ibgp update-source lo
bgp listen range 1.1.1.0/29 peer-group ibgp
address-family l2vpn evpn
neighbor ibgp activate
neighbor ibgp route-reflector-client
exit-address-family
router ospf
network 0.0.0.0/0 area 0
line vty
EOF

# Router 2

vtysh << EOF
configure terminal
no ipv6 forwarding
interface eth1
ip address 10.1.1.2/30
ip ospf area 0
interface lo
ip address 1.1.1.2/32
ip ospf area 0
router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
router ospf
EOF

# Router 3

vtysh << EOF
configure terminal
no ipv6 forwarding
interface eth1
ip address 10.1.1.6/30
ip ospf area 0
interface lo
ip address 1.1.1.3/32
ip ospf area 0
router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
router ospf
EOF

# Router 4

vtysh << EOF
configure terminal
no ipv6 forwarding
interface eth1
ip address 10.1.1.10/30
ip ospf area 0
interface lo
ip address 1.1.1.4/32
ip ospf area 0
router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
router ospf
EOF
