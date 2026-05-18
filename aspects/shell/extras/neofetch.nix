{
  flake.modules.homeManager.shell-extras =
    { pkgs, ... }:
    let
      themes = pkgs.fetchFromGitHub {
        owner = "Chick2D";
        repo = "neofetch-themes";
        rev = "ee84d0907ec3f91a95b78bce2a3cefa2f60e540e";
        sha256 = "1w93j276r54z98d0flvzpljimyc08xs5pnp5q2mjlp8a8aiacxsf";
      };
    in
    {
      xdg.configFile."neofetch/config.conf" = {
        source = "${themes}/normal/config.conf";
      };
    };
}
