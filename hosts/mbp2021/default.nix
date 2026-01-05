{
  inputs,
  config,
  ...
}:
{
  clan.inventory.machines.mbp2021.machineClass = "darwin";
  clan.machines.mbp2021 = {
    clan.core.networking = {
      buildHost = "mrene@mathieus-macbook-pro";
      targetHost = "root@mathieus-macbook-pro";
    };
    imports = [
      inputs.home-manager.darwinModules.home-manager
      # Darwin aspects
      config.flake.modules.darwin.desktop-fonts
      config.flake.modules.darwin.infra-tailscale-networking
      # Host-specific
      config.flake.modules.darwin.mbp2021
      config.flake.darwinModules.overlay
      (
        { self, ... }:
        {
          home-manager.extraSpecialArgs = { inherit inputs self; };
          home-manager.sharedModules = with self.modules.homeManager; [
            # Core
            core-minimal
            core-ssh

            # Shell
            shell-fish
            shell-wezterm

            # Dev
            dev-git
            dev-jujutsu

            # System
            system-common
          ];
        }
      )
    ];
  };

  # Alias for the actual hostname
  flake.darwinConfigurations.Mathieus-MacBook-Pro = config.flake.darwinConfigurations.mbp2021;
}
