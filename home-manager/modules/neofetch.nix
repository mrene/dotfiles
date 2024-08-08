{pkgs, ...}: let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "24db273c85078cb048ac8e19e065fb5cf98fa7fa";
    sha256 = "1rbry4sii27mrgiiq7mz5nk2pdgv79via74brh4dghfxlb4l554g";
  };
in {
  #home.packages = [pkgs.neofetch];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
