{ pkgs }:

{
  services.udev.packages = [ pkgs.uhd ];
 }
