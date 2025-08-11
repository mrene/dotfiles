{pkgs, ...}: let
  # https://github.com/NixOS/nixpkgs/issues/400317
  # Build error:
  #  > expr: syntax error: unexpected argument '41911289'
  oldPkgs = import (builtins.getFlake "github:nixos/nixpkgs/ff618e29610a44a30966bbc3f1a0d5ae95ac8fda") {
    inherit (pkgs) system config;
  };
  ides = with pkgs; [
    jetbrains.webstorm
    jetbrains.goland
    jetbrains.pycharm-professional
    jetbrains.datagrip
    jetbrains.clion
  ];
in {
  environment.systemPackages = with pkgs;
    [
      jetbrains.datagrip
    ]
    ++ builtins.map (ide: (jetbrains.plugins.addPlugins ide ["ideavim"])) ides;
}
