{ pkgs ? import <nixpkgs> {} }:

{
  claude-code = pkgs.callPackage ./package.nix {};
}