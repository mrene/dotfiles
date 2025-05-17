
{
  pkgs,
  windsurf,
  callPackage,
}:

let 
  vscode = windsurf;
in

pkgs.vscode-with-extensions.override {
  vscodeExtensions = callPackage ../vscode-with-extensions/extensions.nix { inherit vscode; };
  inherit vscode;
}
