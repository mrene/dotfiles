{pkgs, ...}: let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "3ea7c37ae791aa31240434dbda2e0cb387d1ddfe";
    sha256 = "15lnk0n04f2a4qk39ccjx0ri0kblbs70sl2w709b1x9qk16vblkf";
  };
in {
  home.packages = [pkgs.neofetch];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
