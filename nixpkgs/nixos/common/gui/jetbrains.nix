{ pkgs }:
{
  environment.systemPackages = with pkgs; [
    jetbrains.goland
    jetbrains.pycharm-professional
    jetbrains.datagrip
    jetbrains.clion
  ];
}