{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = { system, pkgs, ... }: {
    devshells.default = {
      commands = [
        { name = "flake-update"; command = "nix flake update"; help = "Updates flake references"; }
        { name = "package-update"; command = "nix-update -F $1"; help = "Updates packages using nix-update"; }
      ];

      packages = [
        inputs.nix-update.packages.${system}.default
      ];
    };

    devShells.installer = pkgs.mkShell {
      buildInputs = with pkgs; [
        inputs.nixos-generators.packages.${system}.nixos-generate
        nixos-install-tools
      ];
    };
  };
}
