_: {
  flake.aspects.dev-gui-dev.nixos =
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
