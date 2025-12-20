{ lib, ... }:
{
  flake.modules.homeManager.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.system.neofetch;
      themes = pkgs.fetchFromGitHub {
        owner = "Chick2D";
        repo = "neofetch-themes";
        rev = "f3e79d3f36aec02cf42fc772984091990f27a1a3";
        sha256 = "11mkp1g2vc0311lrjhgacrpbl69anpcl6p1qz323i8lgqasja43x";
      };
    in
    {
      options.homelab.system.neofetch = {
        enable = lib.mkEnableOption "Enable neofetch system info tool";
      };

      config = lib.mkIf cfg.enable {
        #home.packages = [pkgs.neofetch];
        xdg.configFile."neofetch/config.conf" = {
          source = "${themes}/normal/config.conf";
        };
      };
    };
}
