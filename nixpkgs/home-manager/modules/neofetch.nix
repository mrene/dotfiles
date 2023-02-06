{ config, pkgs, lib, libs, ... }:
let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "2885c6e39fff30bc8bbb7687107eaae087737704";
    hash = "sha256-mH+3DmQrD8bjcu927D8z9QCW6gwvn+ecrHlMs+OVyoo=";
  };
in
{
  home.packages = [ pkgs.neofetch ];
  home.file.".config/neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
