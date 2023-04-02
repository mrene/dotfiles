{ config, pkgs, lib, libs, ... }:
let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "f20b385177ad417aad9df4aeaadf5e839c472959";
    sha256 = "1n8ss24b5racyl2inya6p0rgsmpsij13bmk2gqpifz3wvnb6qdsn";
  };
in
{
  home.packages = [ pkgs.neofetch ];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
