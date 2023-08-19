{ pkgs, ... }:
let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "c7392136bed264258c9b8788b14410e1ff06d602";
    sha256 = "1wd9h3yasmzh6hvgg17bsmbj344psfmyz4r72fqwpkm4rnbsl30x";
  };
in
{
  home.packages = [ pkgs.neofetch ];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
