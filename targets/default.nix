{
  self,
  nixos-generators,
  microvm,
  jetpack-nixos,
  nixos-riscv64,
}: rec {
  packages.x86_64-linux.vm = nixos-generators.nixosGenerate rec {
    system = "x86_64-linux";
    modules = [
      microvm.nixosModules.host
      ../configurations/host/configuration.nix
      ../modules/development/authentication.nix
      ../modules/development/ssh.nix
      ../modules/development/nix.nix

      ../modules/graphics/weston.nix

      ../configurations/host/networking.nix
      (import ../configurations/host/microvm.nix {
        inherit self system;
      })
    ];
    format = "vm";
  };

  packages.x86_64-linux.intel-nuc = nixos-generators.nixosGenerate rec {
    system = "x86_64-linux";
    modules = [
      microvm.nixosModules.host
      ../configurations/host/configuration.nix
      ../modules/development/intel-nuc-getty.nix
      ../modules/development/nix.nix
      ../modules/development/authentication.nix
      ../modules/development/ssh.nix
      ../modules/development/nix.nix

      ../modules/graphics/weston.nix

      ../configurations/host/networking.nix
      (import ../configurations/host/microvm.nix {
        inherit self system;
      })
    ];
    format = "raw-efi";
  };

  packages.x86_64-linux.default = self.packages.x86_64-linux.vm;

  packages.aarch64-linux.nvidia-jetson-orin = nixos-generators.nixosGenerate (
    import ./nvidia-jetson-orin.nix {inherit self jetpack-nixos microvm;}
    // {
      format = "raw-efi";
    }
  );

  # Using Orin as a default aarch64 target for now
  packages.aarch64-linux.default = self.packages.aarch64-linux.nvidia-jetson-orin;

  packages.riscv-linux.riscv-dev = nixos-generators.nixosGenerate (
    import ./riscv-dev.nix {inherit self;}
    // {
      # TODO: raw probably not enough. Possibly create custom_format target,
      # which puts u-boot and filesystem into the disk the right way. This has
      # been already done for Raspberry Pi and iMX8QM so there are probably
      # good examples.
      # There are some package-examples already here, these could be extended:
      # https://github.com/zhaofengli/nixos-riscv64/tree/master/pkgs
      format = "raw";
    }
  );
}
