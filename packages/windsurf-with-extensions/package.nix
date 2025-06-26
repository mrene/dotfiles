
{
  pkgs,
  callPackage,
  inputs,
  system ? builtins.currentSystem,
}:

let 
  vscode = inputs.mrene-nur.packages.${system}.windsurf;
in

pkgs.vscode-with-extensions.override {
  vscodeExtensions = callPackage ../vscode-with-extensions/extensions.nix { inherit vscode; };
  inherit vscode;
}
