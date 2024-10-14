{pkgs, ...}: let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "a52b4c23d26b0ccae8fce9a824dd2fbadcd9fe01";
    sha256 = "0j9jg6q11z8b6dxz2qw5cc183abkz1m5wr7czc70dcnamhgkkh4m";
  };
in {
  #home.packages = [pkgs.neofetch];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
