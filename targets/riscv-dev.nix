{self}: rec {
  system = "riscv64-linux";
  modules = [
    ../configurations/host/configuration.nix

    # Enable cross-compilation
    {
      nixpkgs.buildPlatform.system = "x86_64-linux";
      nixpkgs.hostPlatform.system = "riscv64-linux";
    }

    #### on-host development supporting modules ####
    # drop/replace modules below this line for any real use
    ../modules/development/authentication.nix
    ../modules/development/ssh.nix
    ../modules/development/nix.nix
    ../modules/development/packages.nix
  ];
}
