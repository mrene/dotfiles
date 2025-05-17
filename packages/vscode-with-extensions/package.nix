{
  pkgs,
  callPackage,
}:

pkgs.vscode-with-extensions.override {
  vscodeExtensions = callPackage ./extensions.nix { };
}
