#!/bin/bash

# ===

ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up

brctl addif br0 vxlan10
brctl addif br0 eth1

# ===

source /usr/lib/frr/frrcommon.sh
/usr/lib/frr/watchfrr $(daemon_list)
