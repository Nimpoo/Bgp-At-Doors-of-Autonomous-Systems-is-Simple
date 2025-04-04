# Partie 3

# Step 1 : Setup the <u>Route Reflector</u>

```sh
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
```

- `vtysh << EOF` : Ouvre le heredoce qui enverra les commandes suivante à vtysh
- `configure terminal` : Passe en mode **configuration** (dans vtysh), permettant de modifier la configuration du routeur
- `no ipv6 forwarding` : Désactive le forwarding IPv6 sur le routeur, cela signifie que le routeur ne transmettra pas les paquets IPv6
- `interface ethX/lo` : Sélectionne l'interface réseau ethX (ou loopback avec `lo`) pour la configuration.
- `ip address 0.0.0.0/0` : Assigne l'adresse IP 0.0.0.0 avec un masque de sous-réseau /0 à l'interface eth0
- `router bgp 1` : Entre dans le mode de **configuration BGP pour l'AS** (Autonomous System) **numéro 1**
- `neighbor ibgp peer-group` : Crée un groupe de pairs BGP nommé **`ibgp`**
- `neighbor ibgp remote-as 1` : Configure les voisins dans le groupe ibgp pour appartenir à l'AS 1
- `neighbor ibgp update-source lo` : Configure les voisins dans le groupe ibgp pour utiliser l'interface loopback comme source des mises à jour BGP
- `bgp listen range 1.1.1.0/29 peer-group ibgp` : Configure le routeur pour écouter les connexions BGP entrantes sur la plage d'adresses 1.1.1.0/29 et les associer au groupe de pairs `ibgp`
- `address-family l2vpn evpn` : Entre dans le mode de configuration de la **famille d'adresses L2VPN EVPN** (Ethernet VPN)
- `neighbor ibgp activate` : Active la famille d'adresses EVPN pour les voisins dans le groupe `ibgp`
- `neighbor ibgp route-reflector-client` : Configure les voisins dans le groupe `ibgp` comme clients du **route reflector**. Cela signifie que le routeur agira comme un route reflector pour ces voisins
- `exit-address-family` : Quitte le mode de configuration de la famille d'adresses EVPN
- `router ospf` : Entre dans le mode de configuration OSPF
- `network 0.0.0.0/0 area 0` : 
- `line vty` : Sélectionne les lignes VTY (Virtual Terminal) pour la configuration
- `EOF` : Termine le heredoc

## Explication global de ce script :

1. <u>**Route Reflector**</u> :

Le routeur est configuré comme un route reflector BGP, ce qui signifie qu'il centralise les mises à jour de routage pour les voisins BGP dans le même AS. Cela réduit le nombre de sessions BGP nécessaires entre les routeurs.

2. <u>**EVPN**</u> :

EVPN est utilisé pour créer des réseaux virtuels isolés (VNIs) qui peuvent s'étendre sur plusieurs sites. Le route reflector annonce ces VNIs à ses voisins BGP, permettant ainsi aux hôtes de communiquer comme s'ils étaient sur le même réseau local.<br />Le routeur est configuré pour activer EVPN pour tous les voisins BGP dans le groupe ibgp. Cela permet de distribuer les informations de routage Layer 2 à travers le réseau.

3. <u>**VTEPs (VXLAN Tunnel Endpoints)**</u> :

Bien que le script ne mentionne pas explicitement les VTEPs, dans un contexte EVPN, les VTEPs sont les points d'extrémité des tunnels VXLAN qui encapsulent et décapsulent le trafic Ethernet.<br />Le route reflector aiderait à distribuer les informations de routage entre les VTEPs, permettant ainsi aux hôtes connectés à différents VTEPs de communiquer entre eux.

# Step 2 : Setup the <u>VTEPs</u>

```sh
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
```

- `ip link add br0 type bridge` : Crée une nouvelle interface `br0` de type `bridge`
- `ip link set dev br0 up` : Active l'interface `br0`
- `ip link add vxlan10 type vxlan id 10 dstport 4789` : Crée une nouvelle interface `vxlan10` de type `vxlan` avec comme id `10` et le port de destination 4789
- `ip link set dev vxlan10 up` : Active l'interfacw `vxlan10`
- `brctl addif br0 vxlan10` : Ajoute l'interface `vxlan10` au bridge `br0`
- `brctl addif br0 eth0` : Ajoute l'interface `eth0` au bridge `br0`

<br />

- `vtysh << EOF` : Ouvre le heredoce qui enverra les commandes suivante à vtysh
- `configure terminal` : Passe en mode **configuration** (dans vtysh), permettant de modifier la configuration du routeur
- `no ipv6 forwarding` : Désactive le forwarding IPv6 sur le routeur, cela signifie que le routeur ne transmettra pas les paquets IPv6
- `ip address 10.1.1.$((-6 + $router_id * 4))/30` : Assigne une adresse IP calculée dynamiquement à l'interface `eth1`. La partie `$((-6 + $router_id * 4))` est une expression arithmétique qui utilise la variable `router_id` pour déterminer le dernier octet de l'adresse IP
- `ip ospf area 0` : Configure l'interface eth1 pour participer à OSPF dans l'aire 0
- `interface lo` : Sélectionne l'interface loopback `lo` pour la configuration.
- `ip address 1.1.1.$router_id/32` : Assigne une adresse IP à l'interface loopback en utilisant la variable `router_id` pour déterminer le dernier octet
- `router bgp 1` : Entre dans le **mode de configuration BGP pour l'AS** (Autonomous System) **numéro 1**
- `neighbor 1.1.1.1 remote-as 1` : **Configure un voisin BGP avec l'adresse IP 1.1.1.1 appartenant à l'AS 1**
- `address-family l2vpn evpn` : Entre dans le mode de configuration de la famille d'adresses L2VPN EVPN (Ethernet VPN)
- `neighbor 1.1.1.1 activate` : Active la famille d'adresses EVPN pour le voisin BGP 1.1.1.1
- `advertise-all-vni` : Configure le routeur pour annoncer tous les VNIs (Virtual Network Identifiers) à ses voisins BGP
- `exit-address-family` : Quitte le mode de configuration de la famille d'adresses EVPN
- `router ospf` : Entre dans le mode de configuration OSPF
- `EOF` : Termine le heredoc

## Explication global de ce script :

1. <u>**Pont Réseau et VXLAN**</u> :

Un pont réseau (`br0`) est créé pour interconnecter plusieurs interfaces réseau, y compris une interface VXLAN (`vxlan10`). Cela permet aux machines sur l'interface physique eth0 de communiquer avec celles sur le réseau VXLAN.<bt />L'interface VXLAN encapsule le trafic Ethernet dans des paquets UDP, permettant l'extension de réseaux Layer 2 sur un réseau IP.

2. <u>**EVPN**</u> :

EVPN est utilisé pour annoncer les VNIs aux voisins BGP, facilitant ainsi la communication entre les sites distants.<br />Le routeur est configuré pour activer EVPN pour le voisin BGP 1.1.1.1, permettant la distribution des informations de routage Layer 2.

3. <u>**VTEP**</u> :

Dans ce script, le routeur lui-même agit comme un VTEP, encapsulant et décapsulant le trafic Ethernet via l'interface VXLAN.<br />EVPN permet aux VTEPs de découvrir dynamiquement les hôtes distants et d'établir des chemins de communication optimaux entre eux.

# Le role de `EVPN` dans un réseau :

### EVPN (Ethernet VPN) est une technologie qui permet d'étendre des réseaux Layer 2 sur un réseau IP en utilisant BGP comme protocole de contrôle.

- Il est particulièrement utile dans les environnements de data centers et les réseaux WAN pour fournir une connectivité Layer 2 entre des sites distants.
- EVPN permet de créer des réseaux virtuels isolés (VNI) qui peuvent être étendus sur plusieurs sites, facilitant ainsi la mobilité des machines virtuelles et la redondance des réseaux.
- En utilisant BGP pour annoncer les informations de routage EVPN, les routeurs peuvent apprendre dynamiquement les réseaux distants et ajuster leurs tables de routage en conséquence.

# Que se passe-t-il si `EVPN` n'est pas utilisé dans notre cas ?

## 1. Pas d'Extension Layer 2

Sans EVPN, il n'y aurait plus d'extension de réseaux Layer 2 sur le réseau IP. Cela signifie que les hôtes qui dépendent de la connectivité Layer 2 entre différents sites <u>**ne pourraient plus communiquer comme s'ils étaient sur le même réseau local**</u>

## 2. Pas de Mobilité Transparente des Machines Virtuelles (pas dans notre cas ici)

EVPN facilite la mobilité des machines virtuelles entre différents sites en maintenant leur connectivité réseau. Sans EVPN, déplacer une machine virtuelle d'un site à un autre nécessiterait une reconfiguration manuelle du réseau, ce qui complique la gestion et réduit la flexibilité.

## 3. Pas de Redondance Layer 2

EVPN permet de créer des chemins redondants pour les réseaux Layer 2, améliorant ainsi la résilience du réseau. Sans EVPN, la redondance devrait être gérée par d'autres mécanismes, potentiellement moins efficaces ou plus complexes à configurer.

## 4. Simplification de la Configuration BGP

La configuration BGP serait simplifiée car il n'y aurait plus besoin de gérer les familles d'adresses EVPN. Cependant, cela réduirait également les capacités du réseau à gérer des réseaux virtuels isolés (VNI).

## 5. Pas de Route Reflector pour EVPN

Dans le premier script, le routeur agit comme un route reflector pour les routes EVPN. Sans EVPN, cette fonctionnalité ne serait plus nécessaire, mais cela limiterait également la capacité du réseau à distribuer efficacement les informations de routage Layer 2.

## 6. Réduction de l'Utilisation des Ressources


Sans EVPN, il y aurait moins de tables de routage et d'états à maintenir sur les routeurs, ce qui pourrait réduire l'utilisation des ressources CPU et mémoire. Cependant, cela se ferait au détriment des fonctionnalités avancées de réseau.

# Rôle des VTEPs dans EVPN

- VTEPs sont les points d'extrémité des tunnels VXLAN qui permettent l'encapsulation et la décapsulation du trafic Ethernet. Ils jouent un rôle crucial dans l'extension des réseaux Layer 2 sur un réseau IP.
- Dans un réseau EVPN, les VTEPs utilisent BGP pour échanger des informations de routage, y compris les adresses MAC et les adresses IP des hôtes connectés. Cela permet une communication transparente entre les hôtes situés sur différents sites ("différents sites" pour une entreprise par exemple).
- Les VTEPs utilisent les informations de routage EVPN pour encapsuler le trafic Ethernet dans des paquets VXLAN et l'envoyer sur le réseau IP, permettant ainsi l'extension des réseaux Layer 2.

# <u>Pour conclure avec ces scripts</u>

**Les deux scripts utilisent EVPN pour étendre des réseaux Layer 2 sur un réseau IP, facilitant ainsi la communication entre les hôtes distants.**

1. Le premier script configure un **route reflector BGP** pour <u>**centraliser les mises à jour de routage EVPN**</u>
2. Le second script utilise un **pont réseau (`bridge`) avec VXLAN pour interconnecter les réseaux** : <u>**VTEP**</u>. Les VTEPs jouent un rôle clé dans l'encapsulation et la décapsulation du trafic Ethernet, permettant l'extension des réseaux Layer 2 (voir le [Glozzzaire.md](https://github.com/Nimpoo/Bgp-At-Doors-of-Autonomous-Systems-is-Simple/blob/main/Glozzzaire.md)).
