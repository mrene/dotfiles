{
  flake.modules.nixos.desktop-gui =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        slack
        discord
        element-desktop
        signal-desktop
      ];
    };
}
