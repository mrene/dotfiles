{ config, pkgs, pkgsUnstable, libs, ... }:
{
  home.packages = with pkgs; [
    # Shell
    starship # Shell prompt generator
    tmux

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

  ] ++ (with pkgs.bat-extras; [ ## TODO: Move to bat.extraPackages once it's merged in home-manager/release-22.11
    prettybat
    batwatch
    batpipe
    batman
    batgrep
    batdiff
  ]);

  programs.bat = {
    enable = true;

    config = {
      theme = "Cattpuccin-mocha";
    };

    themes = let
      cattpuccin = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
        hash = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
      };
    in {
      Catppuccin-latte = builtins.readFile "${cattpuccin}/Catppuccin-latte.tmTheme";
      Catppuccin-frappe = builtins.readFile "${cattpuccin}/Catppuccin-frappe.tmTheme";
      Catppuccin-macchiato = builtins.readFile "${cattpuccin}/Catppuccin-macchiato.tmTheme";
      Catppuccin-mocha = builtins.readFile "${cattpuccin}/Catppuccin-mocha.tmTheme";
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
  };

  programs.dircolors = {
    enable = true;
  };
}
