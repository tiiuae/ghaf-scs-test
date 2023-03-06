# Copyright 2022-2023 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  description = "Ghaf - Documentation and implementation for TII SSRC Secure Technologies Ghaf Framework";

  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.vedenemo.dev"
      "https://cache.ssrcdevops.tii.ae"
    ];
    extra-trusted-public-keys = [
      "cache.vedenemo.dev:RGHheQnb6rXGK5v9gexJZ8iWTPX6OcSeS56YeXYzOcg="
      "cache.ssrcdevops.tii.ae:oOrzj9iCppf+me5/3sN/BxEkp5SaFkHfKTPPZ97xXQk="
    ];
  };

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "/home/mika/nixpkgs.git";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      # url = "github:nix-community/nixos-generators";
      url = "/home/mika/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    microvm = {
      # TODO: change back to url = "github:astro/microvm.nix";
      # url = "github:mikatammi/microvm.nix/wip_hacks_2";
      url = "/home/mika/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    jetpack-nixos = {
      url = "github:anduril/jetpack-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    robotnix = {
      url = "github:danielfullmer/robotnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixos-generators,
    nixos-hardware,
    microvm,
    jetpack-nixos,
    robotnix,
  }: let
    systems = with flake-utils.lib.system; [
      x86_64-linux
      aarch64-linux
    ];
  in
    # Combine list of attribute sets together
    nixpkgs.lib.foldr nixpkgs.lib.recursiveUpdate {} [
      # Documentation
      (flake-utils.lib.eachSystem systems (system: {
        packages = let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          doc = pkgs.callPackage ./docs/doc.nix {};
        };

        formatter = nixpkgs.legacyPackages.${system}.alejandra;
      }))

      {
        robotnixConfigurations."dailydriver" = robotnix.lib.robotnixSystem ({ config, pkgs, ... }: {
          # These two are required options
          device = "crosshatch";
          flavor = "waydroid"; # "grapheneos" is another option

          # buildDateTime is set by default by the flavor, and is updated when those flavors have new releases.
          # If you make new changes to your build that you want to be pushed by the OTA updater, you should set this yourself.
          # buildDateTime = 1584398664; # Use `date "+%s"` to get the current time

          # signing.enable = true;
          # signing.keyStorePath = "/var/secrets/android-keys"; # A _string_ of the path for the key store.

          # Build with ccache
          # ccache.enable = true;
        });

        # This provides a convenient output which allows you to build the image by
        # simply running "nix build" on this flake.
        # Build other outputs with (for example): "nix build .#robotnixConfigurations.dailydriver.ota"
        # defaultPackage.x86_64-linux = self.robotnixConfigurations."dailydriver".img;
      }

      # Target configurations
      (import ./targets {inherit self nixpkgs nixos-generators nixos-hardware microvm jetpack-nixos;})

      # Hydra jobs
      (import ./hydrajobs.nix {inherit self;})
    ];
}
