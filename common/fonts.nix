# REFACTOR PLAN: This file will become:
#   - homelab.fonts.enable (font packages)
# REFACTOR: beware - this file is shared between nix-darwin and nixos
{pkgs, ...}: {
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
}
