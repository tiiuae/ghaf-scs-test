{
  self,
  nixpkgs,
  nixos-generators,
  microvm,
  jetpack-nixos,
}: {
  packages.x86_64-linux.vm = nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    modules = [
      microvm.nixosModules.host
      # .microvm for vm-format "host" to nest vms for system development on x86 (Intel)
      # NOTE: Ghaf nested virtualization is not assumed nor tested yet on AMD
      microvm.nixosModules.microvm

      ../configurations/host/configuration.nix
      ../modules/development/authentication.nix
      ../modules/development/ssh.nix
    ];
    format = "vm";
  };

  packages.x86_64-linux.intel-nuc = let img = nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    modules = [
      microvm.nixosModules.host
      ../configurations/host/configuration.nix
      ../modules/development/intel-nuc-getty.nix
      ../modules/development/authentication.nix
      ../modules/development/ssh.nix
    ];
    format = "raw-efi";
  };
  in
    nixpkgs.legacyPackages.x86_64-linux.stdenvNoCC.mkDerivation {
    name = "intel-nuc";
    src = img;
    installPhase = ''
      mkdir -pv $out
      cp -v * $out/
      mv -v $out/nixos.img $out/intel-nuc-nixos.img
    '';
  };

  packages.x86_64-linux.default = self.packages.x86_64-linux.vm;

  packages.aarch64-linux.nvidia-jetson-orin = nixos-generators.nixosGenerate (
    import ./nvidia-jetson-orin.nix {inherit jetpack-nixos microvm;}
    // {
      format = "raw-efi";
    }
  );

  # Using Orin as a default aarch64 target for now
  packages.aarch64-linux.default = self.packages.aarch64-linux.nvidia-jetson-orin;
}
