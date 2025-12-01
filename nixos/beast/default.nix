{
  inputs,
  config,
  self,
  ...
}:
{
  flake.nixosConfigurations.beast = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit (self) common;
      inherit inputs self;
      flakePackages = config.flake.packages;
    };
    modules = [
      ./configuration.nix
      config.flake.nixosModules.overlay
      config.flake.nixosModules.all
    ];
  };
}
