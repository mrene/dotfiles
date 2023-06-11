{ config, pkgs, lib, libs, ... }:
let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "e743a3737031ca423113de9461965b61d46f6731";
    sha256 = "0sd88z4icc2vk3gxdcf05wdmbjbssjm0r038bj7xjcifpm52anqw";
  };
in
{
  home.packages = [ pkgs.neofetch ];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
