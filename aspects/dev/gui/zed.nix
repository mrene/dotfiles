{
  flake.modules.nixos.dev-gui =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        zed-editor
      ];
    };
}
