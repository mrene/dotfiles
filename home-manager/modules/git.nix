{pkgs, ...}: let
  delta = pkgs.fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "07122749965b6221913aecb037e23fb7351dacf4";
    sha256 = "0x5gv1pjiwjrzijsxa2r732qa6nbmkcxymbzhwnf0vf8rs95882f";
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
