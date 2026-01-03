{
  inputs,
  config,
  ...
}:
{
  # Set machine class to darwin for macOS
  clan.inventory.machines.mbp2021.machineClass = "darwin";

  # Define the darwin machine configuration
  # Build: nix build .#darwinConfigurations.mbp2021.system
  # Switch: darwin-rebuild switch --flake .#mbp2021
  clan.machines.mbp2021.imports = [
    inputs.home-manager.darwinModules.home-manager
    config.flake.modules.darwin.all
    config.flake.modules.darwin.mbp2021
    config.flake.darwinModules.overlay
    ({ self, ... }: {
      home-manager.extraSpecialArgs = { inherit inputs self; };
      home-manager.sharedModules = [ config.flake.modules.homeManager.all ];
    })
  ];

  # Alias for the actual hostname
  flake.darwinConfigurations.Mathieus-MacBook-Pro =
    config.flake.darwinConfigurations.mbp2021;
}
