_:
{
  flake.aspects.dev-gui-dev.nixos =
    {
      pkgs,
      flakePackages,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        flakePackages.${system}.vscode-with-extensions

        gcc
        mypy
        glibc.dev
      ];
    };
}
