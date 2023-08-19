{ inputs, config, ... }:
let
  inherit (inputs) home-manager;
in
{
  flake.homeConfigurations = {
    "mrene@beast" = home-manager.lib.homeManagerConfiguration {
      inherit (config.flake.homeConfigurations.beast) pkgs;
      modules = [ ./beast.nix ];
      extraSpecialArgs = { inherit inputs; };
    };
    "mrene@Mathieus-MBP" = home-manager.lib.homeManagerConfiguration {
      inherit (config.flake.darwinConfigurations.Mathieus-MBP) pkgs;
      modules = [ ./mac.nix ];
      extraSpecialArgs = { inherit inputs; };
    };
  };
}
