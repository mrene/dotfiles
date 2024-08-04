{ lib, callPackage, gnuradio }:

let 
  packages = lib.filesystem.packagesFromDirectoryRecursive{
      inherit callPackage;
      directory = ../../scoped-packages/gnuradio;
  };
in 

(gnuradio.override {
  extraPackages = builtins.attrValues packages;
  extraPythonPackages = with gnuradio.python.pkgs; [ soapysdr ];
}) // {
  pkgs = gnuradio.pkgs.overrideScope (final: prev: packages);
}