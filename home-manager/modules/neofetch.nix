{ config, pkgs, lib, libs, ... }:
let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "2885c6e39fff30bc8bbb7687107eaae087737704";
    sha256 = "12najpiv6k3rmjffg7rg1km9c07m6czyqxpgfbiwc3rbch7bfzwq";
  };
in
{
  home.packages = [ pkgs.neofetch ];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
