{ pkgs, ... }:
{
  imports = [
    ./jetbrains.nix
  ];

  environment.systemPackages = with pkgs; [
    vscode-with-extensions

    # These need to be in the global PATH for goland to work correctly
    gcc
    llvmPackages.libclang
    llvmPackages.libcxxClang
    mypy
    glibc.dev
    libclang.lib
  ];
}
