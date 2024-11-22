{pkgs, ...}: let
  delta = pkgs.fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "1fb6f99ec498150f552c1c8b5440152c0c2aade7";
    sha256 = "08wlda8p2qbgfibsy81a1nnl786hc8fk0lhfqq7lzbkbwvxbyghw";
  };
in {
  programs.git = {
    enable = true;
    userName = "Mathieu Rene";
    userEmail = "mathieu.rene@gmail.com";

    delta = {
      enable = true;
      options = {
        navigate = true; # N to switch files
        syntax-theme = "Nord";
        side-by-side = false;
        features = "chameleon-mod";
      };
    };

    extraConfig = {
      github.user = "mrene";

      push.autoSetupRemote = true;

      core.editor = "nvim";
      core.fileMode = false;
      core.ignorecase = false;
      include = {
        path = "${./delta}/themes.gitconfig";
      };
    };
  };
}
