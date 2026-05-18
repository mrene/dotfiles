{
  flake.modules.nixos.dev-gui =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        jetbrains.webstorm
        jetbrains.goland
        jetbrains.pycharm
        jetbrains.datagrip
        jetbrains.clion
      ];
    };
}
