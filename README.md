# Muh Homelab

## OS

> [!NOTE]
> All machines strive to run NixOS.
> The current only exception is the NAS running TrueNAS CE

NixOS is responsible for managing dependencies required for containers, as well
as firewalls.

Containers seem to be the norm within homelabbing, so what would normally be run
as NixOS services, I'll run as a container instead. After enough annoyance, I
might migrate into a ![Quadlet](https://github.com/SEIAROTg/quadlet-nix), or just migrate completely to Nix for
any service that supports it.
