{ config, pkgs, lib, libs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Mathieu Rene";
    userEmail = "mathieu.rene@gmail.com";

    delta = {
      enable = true;
      options = {
        syntax-theme = "solarized-dark";
        side-by-side = true;
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      github.user = "mrene";

      push.autoSetupRemote = true;

      core.editor = "nvim";
      core.fileMode = false;
      core.ignorecase = false;
    };
  };
}
