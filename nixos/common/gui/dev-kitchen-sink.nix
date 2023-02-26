{ pkgs, ... }:
{
  imports = [
    ./jetbrains.nix
  ];

  environment.systemPackages = with pkgs; [
    vscode-with-extensions

    # These need to be in the global PATH for goland to work correctly
    gcc
    mypy
    glibc.dev

    clang-tools_15
    clang_15
  ];
}
