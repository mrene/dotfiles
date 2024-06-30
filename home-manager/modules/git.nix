{pkgs, ...}: let
  delta = pkgs.fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "f5b37173fe88a62e37208a9587a0ab4fec0ef107";
    sha256 = "1silsg28qq6dcjqj5sbivi6k64ggh2z309lqr454yh0cnvb81qzm";
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
