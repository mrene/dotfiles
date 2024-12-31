{pkgs, ...}: {
  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    powerline-fonts

    # Part of nerdfonts
    #powerline-symbols

    source-code-pro
    freefont_ttf
    ibm-plex
    # Part of powerline-fonts
    #hack-font
    fira-code
  ];
}
