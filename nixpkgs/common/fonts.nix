{ pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    powerline-fonts

    # Part of nerdfonts
    #powerline-symbols

    nerdfonts
  ];
}
