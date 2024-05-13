{pkgs, ...}: let
  themes = pkgs.fetchFromGitHub {
    owner = "Chick2D";
    repo = "neofetch-themes";
    rev = "fa4718dcf26e9c1a93a393d4cee58822ac5419a5";
    sha256 = "0gg43d75a4fw004rvhbcmw6jqgahh2qpkwj2a5wjv3980ix403r2";
  };
in {
  home.packages = [pkgs.neofetch];
  xdg.configFile."neofetch/config.conf" = {
    source = "${themes}/normal/config.conf";
  };
}
