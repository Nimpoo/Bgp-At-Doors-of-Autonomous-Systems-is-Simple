# Bgp-At-Doors-of-Autonomous-Systems-is-Simple

### This 42 project is a simple implementation of BGP (Border Gateway Protocol) that allows you to simulate the routing of packets between autonomous systems (AS). The goal is to understand how BGP works and how it can be used to route packets between different networks.

The project is divided into **three** parts:

- **Part 1**: Creation of the **host** and **router** containers with an [image of FRRouting](https://github.com/FRRouting/frr/tree/285fcb903a495f8b4067d6dcade8c2dcbf39e748) and learning how GNS3 works.
- **Part 2**: Creation of the **AS** configuration files (VXLAN, bridge, etc...), and learning how to configure BGP in FRRouting.
- **Part 3**: Creation of the final **topology**, setup of route reflectors, hnowing what is the method of **`BGP-EVPN-VXLAN`**, configuration with `vtysh` and adding a third host to the topology.

We will need A LOT OF DOCUMENTATION to understand what we are supposed to do, so I will try to explain everything in the [Glozzzaire.md](https://github.com/Nimpoo/Bgp-At-Doors-of-Autonomous-Systems-is-Simple/blob/main/Glozzzaire.md) file.

## ALL THE DOCUMENTATION IS NECESSARY TO UNDERSTAND THE PROJECT

Maybe I abused a bit, but I wanted to be sure that I understood everything. It's very complicated to understand BGP, normally a formation is required to understand it.

## 🚨 WARNINGS ABOUT FRROUTING 🚨
### <u>🚨 First Warning 🚨</u>
As you can see in the [walktrhough in the part 2](https://github.com/Nimpoo/Bgp-At-Doors-of-Autonomous-Systems-is-Simple/blob/main/P2/walktrough.md), we create an image of FRRouting, but you can use Quagga or GNU Zebra, but FRRouting may be more up to date and have more features and it's a fork of Quagga (and Quagga a fork of GNU Zebra). So I recommend using FRRouting, but you can use Quagga or GNU Zebra or another Internet routing protocol suite.

### <u>🚨 Second Warning 🚨</u>
If you use FRRouting, you can see we build an image of it for **Debian**. Previously we build an image of FRRouting for **Alpine** but we have noticed that is not working properly with some commands (`ipconfig`, `vtysh`, etc...). Because Alpine has a deprecated version of `Busybox`. And we switched to Debian because it is more stable and has a better support for FRRouting. So I recommend using Debian as the base image for FRRouting.

## Summary

- [P1](P1) : Creation of the **host** and **router** containers with an [image of FRRouting](https://github.com/FRRouting/frr/tree/285fcb903a495f8b4067d6dcade8c2dcbf39e748) and learning how GNS3 works.
- [P2](P2) : Creation of the **AS** configuration files (VXLAN, bridge, etc...), and learning how to configure BGP in FRRouting.
- [P3](P3) : Creation of the final **topology**, setup of route reflectors, knowing what is the method of **`BGP-EVPN-VXLAN`**, configuration with `vtysh` and adding a third host to the topology.

## MADE BY US :

<table>
  <tr>
    <td align="center"><a href="https://github.com/jbettini/"><img src="https://avatars.githubusercontent.com/u/85110911?v=4" width="100px;" alt=""/><br /><sub><b>jbettini</b></sub></a><br /><a href="https://profile.intra.42.fr/users/jbettini" title="Intra 42"><img src="https://img.shields.io/badge/Nice-FFFFFF?style=plastic&logo=42&logoColor=000000" alt="Intra 42"/></a></td>
    <td align="center"><a href="https://github.com/noalexan/"><img src="https://avatars.githubusercontent.com/u/102285721?v=4" width="100px;" alt=""/><br /><sub><b>Noah (noalexan)</b></sub></a><br /><a href="https://profile.intra.42.fr/users/noalexan" title="Intra 42"><img src="https://img.shields.io/badge/Nice-FFFFFF?style=plastic&logo=42&logoColor=000000" alt="Intra 42"/></a></td>
    <td align="center"><a href="https://github.com/nimpoo/"><img src="https://avatars.githubusercontent.com/u/91483405?v=4" width="100px;" alt=""/><br /><sub><b>Nimpô (mayoub)</b></sub></a><br /><a href="https://profile.intra.42.fr/users/mayoub" title="Intra 42"><img src="https://img.shields.io/badge/Nice-FFFFFF?style=plastic&logo=42&logoColor=000000" alt="Intra 42"/></a></td>
  </tr>
</table>
