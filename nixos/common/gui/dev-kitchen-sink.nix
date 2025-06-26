{
  pkgs,
  flakePackages,
  ...
}: {
  imports = [
    ./jetbrains.nix
  ];

  environment.systemPackages = with pkgs; [
    flakePackages.${system}.vscode-with-extensions
    flakePackages.${system}.windsurf-with-extensions

    # These need to be in the global PATH for goland to work correctly
    gcc
    mypy
    glibc.dev

    clang-tools_15
    clang_15
    task-master-ai
  ];
}
