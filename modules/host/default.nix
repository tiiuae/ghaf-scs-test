# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  self,
  microvm,
  netvm,
}: {modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/minimal.nix")

    microvm.nixosModules.host

    (import ./microvm.nix {inherit self netvm;})
    ./networking.nix
  ];

  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
  };

  networking.hostName = "ghaf-host";
  system.stateVersion = "22.11";
}
