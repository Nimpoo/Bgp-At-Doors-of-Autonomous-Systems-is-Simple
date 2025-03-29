router
```sh
config t
hostname router_jbettini-4
no ipv6 forwarding
!
interface eth0
 ip address 20.1.1.4/24
!
interface lo
 ip address 20.1.1.4/32
!
router bgp 4
 bgp router-id 20.1.1.4
 no bgp default ipv4-unicast
 neighbor 20.1.1.1 remote-as 4
 neighbor 20.1.1.1 update-source lo
!
 address-family l2vpn evpn
  neighbor 20.1.1.1 activate
  advertise-all-vni
 exit-address-family
!
router ospf
 network 20.1.1.0/24 area 0
!
```

route reflector
```sh
config t
hostname router_jbettini-1
no ipv6 forwarding
!
interface lo
 ip address 20.1.1.1/32
!
router bgp 1
 bgp router-id 20.1.1.1
 no bgp default ipv4-unicast
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1
 neighbor ibgp update-source lo
 bgp listen range 20.1.1.0/24 peer-group ibgp
!
 address-family l2vpn evpn
  neighbor ibgp activate
  neighbor ibgp route-reflector-client
 exit-address-family
!
router ospf
 network 20.1.1.0/24 area 0
!
```

https://www.perplexity.ai/search/ee2baea6-eb2f-4da8-af2f-eb1186fcd6a7?1=d&login-source=loginButton&login-new=false
