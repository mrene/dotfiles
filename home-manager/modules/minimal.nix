{
  config,
  pkgs,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs;
    [
      # Shell
      tmux

      fzf
      ripgrep
      fd
      eza
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
    ]
    ++ (with pkgs.bat-extras; [
      ## TODO: Move to bat.extraPackages once it's merged in home-manager/release-22.11
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
      theme = "Catppuccin-mocha";
    };

    themes = let
      cattpuccin = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "bat";
        rev = "e5c2f64eab91deb1750233cd64356b26cb985a21";
        sha256 = "0zn41dvppn4mskq6xf171wfv6cgaz4y4x1dvyj6fv5whfvl68r6d";
      };
    in {
      Catppuccin-latte.src = "${cattpuccin}/Catppuccin-latte.tmTheme";
      Catppuccin-frappe.src = "${cattpuccin}/Catppuccin-frappe.tmTheme";
      Catppuccin-macchiato.src = "${cattpuccin}/Catppuccin-macchiato.tmTheme";
      Catppuccin-mocha.src = "${cattpuccin}/Catppuccin-mocha.tmTheme";
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
