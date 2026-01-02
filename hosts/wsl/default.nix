{
  inputs,
  config,
  self,
  ...
}:
{
  # Declare inputs used by this host for flake-file tracking
  flake-file.inputs.nixos-wsl = {
    url = "github:nix-community/NixOS-WSL";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit (self) common;
      inherit inputs self;
      flakePackages = config.flake.packages;
    };
    modules = [
      config.flake.modules.nixos.wsl
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.overlay
      config.flake.modules.nixos.all
    ];
  };
}
