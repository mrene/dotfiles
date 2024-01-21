{pkgs, ...}: let
  uhd = pkgs.uhd.override {
    enableUtils = true;
    enableExamples = true;
  };
in {
  services.udev.packages = [uhd];
}
