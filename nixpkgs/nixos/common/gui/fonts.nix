{ pkgs, ...}: 

{
  fonts.fonts = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    powerline-fonts
    powerline-symbols

    nerdfonts
  ];
}