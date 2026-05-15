_: {
  flake.aspects.core-minimal.homeManager =
    { pkgs, ... }:
    {
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
          tealdeer # fast tldr
          zoxide # habitual `cd`
          any-nix-shell # allows using fish for `nix shell`

          # igrep # interactive grep

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
        extraConfig = ''
          set -s extended-keys on
          set -s extended-keys-format csi-u
          set -as terminal-features 'xterm-ghostty:extkeys'

          # tmux has no named key for shifted arrows or for shifted-punctuation
          # chords with multiple modifiers. Map the raw sequences to UserN keys.
          # Arrows: Ghostty emits XTerm modifyOtherKeys form \e[1;<mod><A-D>.
          # Splits: Ghostty's legacy mode doesn't encode these, so Ghostty's
          # keybind config rewrites them to a custom CSI-u sequence we choose.
          # Mod 6 = Shift(1)+Ctrl(4)+bias(1); Mod 8 = Shift(1)+Alt(2)+Ctrl(4)+bias(1).
          set -s user-keys[0] "\e[1;6A"
          set -s user-keys[1] "\e[1;6B"
          set -s user-keys[2] "\e[1;6C"
          set -s user-keys[3] "\e[1;6D"
          set -s user-keys[4] "\e[39;8u"
          set -s user-keys[5] "\e[53;8u"

          bind -n User0 select-pane -U
          bind -n User1 select-pane -D
          bind -n User2 select-pane -R
          bind -n User3 select-pane -L
          bind -n User4 split-window -v -c "#{pane_current_path}"
          bind -n User5 split-window -h -c "#{pane_current_path}"
        '';
      };

      programs.dircolors.enable = true;
    };
}
