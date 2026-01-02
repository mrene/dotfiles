{
  inputs,
  config,
  self,
  ...
}:
{
  flake.darwinConfigurations = {
    # nix build .#darwinConfigurations.mbp2021.system
    # ./result/sw/bin/darwin-rebuild switch --flake .
    Mathieus-MacBook-Pro = config.flake.darwinConfigurations.Mathieus-MBP;
    Mathieus-MBP = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs {
        config = {
          allowUnfree = true;
        };
        system = "aarch64-darwin";
      };
      modules = [
        config.flake.modules.darwin.mbp2021
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs self; };
          home-manager.sharedModules = [ config.flake.modules.homeManager.all ];
        }
      ];
      specialArgs = { inherit inputs self; };
    };
  };
}
