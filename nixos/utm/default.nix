{
  inputs,
  config,
  self,
  ...
}:
{
  flake.nixosConfigurations.utm = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit (self) common;
      inherit inputs self;
    };
    modules = [
      ./configuration.nix
      config.flake.nixosModules.overlay
      config.flake.nixosModules.all
    ];
  };
}
