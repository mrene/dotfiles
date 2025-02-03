{pkgs, ...}: let
  delta = pkgs.fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "d4017ea9cbf3a1223c88953c61a33d0f20334524";
    sha256 = "02q9si2cr4lsg50wv2sbxgcw6mm9cv6xqdx0iqisswk8w9n78xd9";
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

    lfs.enable = true;

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
