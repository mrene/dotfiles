{
  inputs,
  config,
  ...
}:
{
  clan.inventory.machines.mbpm3.machineClass = "darwin";
  clan.machines.mbpm3 = {
    clan.core.networking = {
      buildHost = "mrene@mrene-mbp-m3";
      targetHost = "root@mrene-mbp-m3";
    };
    imports = [
      inputs.home-manager.darwinModules.home-manager
      # Darwin aspects
      config.flake.modules.darwin.desktop-fonts
      config.flake.modules.darwin.infra-tailscale-networking
      # Host-specific
      config.flake.modules.darwin.mbpm3
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
            dev-ai
            dev-git
            dev-jujutsu

            # Infra
            infra-syncthing

            # System
            system-common
          ];
        }
      )
    ];
  };

  # Alias for the actual hostname
  flake.darwinConfigurations.mrene-mbp-m3 = config.flake.darwinConfigurations.mbpm3;
}
