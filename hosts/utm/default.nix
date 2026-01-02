{
  inputs,
  config,
  self,
  ...
}:
{
  # Declare inputs used by this host for flake-file tracking
  flake-file.inputs.nixos-lima = {
    url = "github:ciderale/nixos-lima";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.nixosConfigurations.utm = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit (self) common;
      inherit inputs self;
    };
    modules = [
      config.flake.modules.nixos.utm
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.overlay
      config.flake.modules.nixos.all
    ];
  };
}
