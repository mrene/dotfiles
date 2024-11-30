{pkgs, ...}: let
  delta = pkgs.fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "31296e7ff72eedf1f3781d5a4f5f807229a92990";
    sha256 = "0hxlgz6c9ypmripz3y65l07ni6vnhd5yxvad939c35iymd54n6vn";
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
