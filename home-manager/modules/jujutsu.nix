{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.dev.jujutsu;
in
{
  options.homelab.dev.jujutsu = {
    enable = lib.mkEnableOption "Enable jujutsu version control";
  };

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
    enable = true;

    # See https://github.com/jj-vcs/jj/blob/main/docs/config.md
    # Some goodies from https://zerowidth.com/2025/jj-tips-and-tricks/#bookmarks-and-branches
    settings = {
      user = {
        name = "Mathieu Rene";
        email = "mathieu.rene@gmail.com";
      };
      ui = {
        paginate = "never";
        default-command = [
          "log"
          "--reversed"
        ];
      };
    };
  };
  };
}
