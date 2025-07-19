{ pkgs, ... }:

{
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
}
