{pkgs, ...}: let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "cef1e10d702ae5dc5865ffd57e1c52b9143fff2f";
    sha256 = "00cvzc50vycb28qjrlwikckf826hy5a9wvmxk8dyaklycp487ckg";
  };
in {
  #home.packages = [pkgs.neofetch];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
