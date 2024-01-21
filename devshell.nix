{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = { system, pkgs, ... }: {
    devshells.default = {
      commands = [
        { name = "flake-update"; command = "nix flake update"; help = "Updates flake references"; }
        { name = "update-git"; command = "update-nix-fetchgit $(rg --files-with-matches fetchFrom $PRJ_ROOT)"; help = "Update git fetch expressions"; }
        { name = "package-update"; command = "nix-update -F $1"; help = "<package> Updates local package (from packages/) using nix-update"; }
        { name = "update-sources"; command = "nvfetcher"; help = "Updates all sources defined in nvfetcher.toml"; }
      ];

      packages = [
        inputs.nix-update.packages.${system}.default
        pkgs.nvfetcher
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
