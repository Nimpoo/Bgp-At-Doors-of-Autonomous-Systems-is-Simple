#!/bin/bash

router_id="$(hostname | sed 's/router_.*-//g')"

if [ "$router_id" = "1" ]; then

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

else

ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up

brctl addif br0 vxlan10
brctl addif br0 eth0

vtysh << EOF
configure terminal
no ipv6 forwarding
interface eth1
ip address 10.1.1.$((-6 + $router_id * 4))/30
ip ospf area 0
interface lo
ip address 1.1.1.$router_id/32
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

fi
