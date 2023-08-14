{ ... }:
{
  perSystem = { system, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        nixos-generators.packages.${system}.nixos-generate
        nixos-install-tools
      ];
    };
  };
}
