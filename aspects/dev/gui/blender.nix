{
  flake.modules.nixos.dev-gui =
    {
      pkgs,
      flakePackages,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        flakePackages.${stdenv.hostPlatform.system}.vscode-with-extensions

        gcc
        mypy
        glibc.dev
      ];
    };
}
