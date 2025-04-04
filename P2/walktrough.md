# Partie 2

# Step 1

Clone : 
```sh
git clone https://github.com/FRRouting/frr.git
```
# Step 2

Build frr routing image :

```sh
pushd frr/docker/debian
    docker build -t frr:latest .
popd
```

# Step 3 

Build docker host and router docker images :

```sh
docker build -f router_ -t router_jbettini:P2 .
docker build -f host_ -t host_jbettini:P2 .
```

# Step 4

Run Gns3 and create template using our docker images, link all as the subject rules

# Step 5 

`Setup.sh` explanation

```sh
#!/bin/bash

# Création du bridge br0 (couche L2)
ip link add br0 type bridge
ip link set dev br0 up

# Configuration IP sous-réseau underlay (communication entre VTEP)
# Adresse IP = 10.1.1.X/24 où X = numéro du routeur (1 ou 2)
ip addr add 10.1.1.$(hostname | tr -d 'router_jbettini-')/24 dev eth0

# Création interface VXLAN avec configuration multicast
ip link add name vxlan10 type vxlan \
    id 10 \                   # VNI (VXLAN Network Identifier)
    dev eth0 \                # Rattache vxlan a eth0 (reseau underlay)
    group 239.1.1.1 \         # Assigne a un group Vtep permetant le multicast
    dstport 4789              # Port UDP standard VXLAN

# Configuration IP overlay (optionnel selon besoin)
ip addr add 20.1.1.$(hostname | tr -d 'router_jbettini-')/24 dev vxlan10

# Ajout des interfaces au bridge
brctl addif br0 eth1    # Interface physique vers les hôtes locaux
brctl addif br0 vxlan10 # Interface VXLAN pour le tunnel

# Activation des interfaces
ip link set dev vxlan10 up

# Entrypoint du dockerfile de frrouting
source /usr/lib/frr/frrcommon.sh
/usr/lib/frr/watchfrr $(daemon_list)
```
