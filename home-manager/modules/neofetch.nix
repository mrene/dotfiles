{ config, pkgs, lib, libs, ... }:
let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "75d72de3c641f037a9bfb3d0f2827addf2ef3fb7";
    sha256 = "1zrb82jjpyv9k1mzyic60bzpk2crp3qjv1bivq1p11l73124p8w4";
  };
in
{
  home.packages = [ pkgs.neofetch ];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
