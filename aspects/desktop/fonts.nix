_:
let
  # Shared font packages for both NixOS and nix-darwin
  fontPackages = pkgs: with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    powerline-fonts
    source-code-pro
    freefont_ttf
    ibm-plex
    fira-code
    nerd-fonts.fira-code
  ];

  # Shared module definition for both platforms
  mkFontsModule =
    { pkgs, ... }:
    {
      fonts.packages = fontPackages pkgs;
    };
in
{
  flake.aspects.desktop-fonts = {
    nixos = mkFontsModule;
    darwin = mkFontsModule;
  };
}
