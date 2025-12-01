{ lib, ... }:
{
  flake.nixosModules.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.fonts;
    in
    {
      options.homelab.fonts = {
        enable = lib.mkEnableOption "Enable homelab font packages";
      };

      config = lib.mkIf cfg.enable {
        # Note: This file is shared between nix-darwin and nixos
        fonts.packages = with pkgs; [
          jetbrains-mono
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          powerline-fonts

          # Part of nerdfonts
          #powerline-symbols

          source-code-pro
          freefont_ttf
          ibm-plex
          # Part of powerline-fonts
          #hack-font
          fira-code
          nerd-fonts.fira-code
        ];
      };
    };
}
