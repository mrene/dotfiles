{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    powerline-fonts

    # Part of nerdfonts
    #powerline-symbols

    #nerdfonts
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    freefont_ttf
    ibm-plex
    # Part of powerline-fonts
    #hack-font
    fira-code
  ];
}
