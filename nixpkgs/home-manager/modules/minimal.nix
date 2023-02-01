{ config, pkgs, pkgsUnstable, libs, ... }:
{
    home.packages = with pkgs; [
      # Shell
      starship  # Shell prompt generator
      tmux

      bat   # cat with syntax highlighting

      fzf 
      ripgrep 
      fd
      exa
      neofetch # fancy system + hardware info
      tealdeer # fast tldr
      zoxide # habitual `cd`
      any-nix-shell # allows using fish for `nix shell`
      igrep # interactive grep

      nvd # nix package diff tool

      tree

      # Disk space estimators
      dua 
      du-dust

      # JSON tooling
      jq
      jless

      # System status
      bottom
      htop

      git 

    ];

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.dircolors = {
    enable = true;
  };
}
