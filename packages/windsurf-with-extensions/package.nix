
{
  pkgs,
  callPackage,
}:

let 
  vscode = pkgs.windsurf;
in

pkgs.vscode-with-extensions.override {
  vscodeExtensions = callPackage ../vscode-with-extensions/extensions.nix { inherit vscode; };
  inherit vscode;
}
