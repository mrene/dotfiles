{ config, ... }:
{
  flake.modules.homeManager.shell-extras = _: {
    xdg.configFile."neofetch/config.conf" = {
      source = "${config.npins.neofetch-themes}/normal/config.conf";
    };
  };
}
