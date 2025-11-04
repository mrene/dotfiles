{pkgs, ...}: let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "e9b1767932bad3f7f89869f040965160c8d03b3e";
    sha256 = "19shawvpvik13sa9pf59djz2ymyrv0c7jqh3pd0knzla2sk40327";
  };
in {
  #home.packages = [pkgs.neofetch];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
