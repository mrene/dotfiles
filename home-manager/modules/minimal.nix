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
      # Snapshot testing error on the reported version which is surely due to nix shenanigans
      (batdiff.overrideAttrs { doCheck = false; })
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
        rev = "699f60fc8ec434574ca7451b444b880430319941";
        sha256 = "1lirgwgh2hnz6j60py19bbmhvgaqs7i6wf6702k6n83lgw4aixg9";
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
