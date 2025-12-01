{ lib, ... }:
{
  flake.modules.homeManager.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.minimal;
    in
    {
      options.homelab.minimal = {
        enable = lib.mkEnableOption "Enable minimal home-manager configuration";
      };

      config = lib.mkIf cfg.enable {
        # Let Home Manager install and manage itself.
        programs.home-manager.enable = true;

        home.packages =
          with pkgs;
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
            dust

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
            #batgrep
            # Snapshot testing error on the reported version which is surely due to nix shenanigans
            (batdiff.overrideAttrs { doCheck = false; })
          ]);

        programs.bat = {
          enable = true;

          config = {
            theme = "Catppuccin-mocha";
          };

          themes =
            let
              cattpuccin = pkgs.fetchFromGitHub {
                owner = "catppuccin";
                repo = "bat";
                rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
                sha256 = "1y5sfi7jfr97z1g6vm2mzbsw59j1jizwlmbadvmx842m0i5ak5ll";
              };
            in
            {
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
      };
    };
}
