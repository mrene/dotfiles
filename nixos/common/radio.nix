{ pkgs, ... }:

let
  uhd = pkgs.uhd.override (old: {
    enableUtils = true;
    enableExamples = true;
  });
in

{
  services.udev.packages = [ uhd ];
}
