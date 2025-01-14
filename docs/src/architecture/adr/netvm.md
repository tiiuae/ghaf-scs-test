<!--
    Copyright 2023 TII (SSRC) and the Ghaf contributors
    SPDX-License-Identifier: CC-BY-SA-4.0
-->

# netvm - Networking Virtual Machine

## Status

Proposed, partially implemented. Bridged for development and testing.

netvm reference declaration is available at [netvm/default.nix](https://github.com/tiiuae/ghaf/blob/main/configurations/netvm/default.nix)

## Context

Ghaf high level design target is to secure a monolithic operating system (OS) by modularizing the OS to networked virtual machines. The key security target is to not expose the trusted host directly to the internet. This isolates the attack surface from the internet to the netvm.

The following context diagram illustrates development and secure scenarios:

![Scope!](../../img/netvm.drawio.png "netvm Context")

**Left**: An unsecure development scenario where the host is directly connected to the internet and the network is bridged from the host to other parts of the system.

**Right**: Secure scenario where the network is passed through to the netvm and routed to other parts of the system.

## Decision

The development scenario simplifies the target system network access and configuration. This ADR proposes the development netvm configuration is maintained to support system development.

The secure scenario is proposed to be implemented with use of passthrough to direct-memory access (DMA) remap the host physical network interface card (PHY NIC) to the netvm. This cannot be generalized for all hardware targets as requires:
- Low-level device tree configuration for bootloader and host (at least on platform NIC)
- Virtual Machine Manager (VMM) host user space NIC bus mapping from the host to the netvm
- Native network interface driver (not virtual) in the netvm. Native driver is bound the vendor BSP supported kernel version.

These depend on the hardware setup. Proposed target setup is that the passthrough network device(s) are implemented as declarative nix-modules for easier user hardware specific configuration. In practice, the user may configure the declaration of a PCI or USB network card that is available to the available hardware setup.

The netvm will provide:
- dynamic network configuration:
  - DHCP (dynamic host configuration protocol) server for the netvm to provide the IP addresses for the other parts of the system - both static and dynamic.
  - routing - from netvm to internet and/or inter VM

For common reference hardware with platform NIC, the configured modules for network interface passthrough are provided (if possible, see [notes on i.MX 8QM Ethernet Passthroug](https://tiiuae.github.io/ghaf/research/passthrough/ethernet.html)).

Details of other network components, such as default firewall rules, DHCP (static and dynamic client addresses), routing, reverse proxies and security monitoring are to be described in their respective architecture decision records. In this context, these are illustrated in the context diagram on the right side of the netvm network interface driver. 

## Consequences

Isolating the attack surface from host to networking specific guest VM makes it easier protect the critical host system from comporimise. The isolation also makes it easier to deploy further security, such as zero trust policy engine or intrusion detection system (IDS), in the netvm.

Isolation makes configuration and comprehension of the system more difficult.

