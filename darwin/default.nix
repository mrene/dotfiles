{
  inputs,
  config,
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
        ./mbp2021/configuration.nix
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.sharedModules = [ config.flake.modules.homeManager.all ];
        }
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
