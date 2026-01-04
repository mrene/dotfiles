_:
{
  flake.aspects.desktop-gui-messaging.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        slack
        discord
        element-desktop
      ];
    };
}
