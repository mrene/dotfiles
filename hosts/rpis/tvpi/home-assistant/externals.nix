{ inputs, ... }:
{
  flake-file.inputs.nix-externals = {
    url = "github:mrene/nix-externals";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.nix-externals.flakeModule ];

  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      npins = import ../../../../npins;
      inherit (npins.hydroqc2mqtt) version;
    in
    {
      externals.stateDir = ../../../../_externals;

      externals.hydroqc2mqtt = {
        cacheKey = version;
        producer = ''
          ${lib.getExe pkgs.nix-prefetch-docker} \
            --image-name registry.gitlab.com/hydroqc/hydroqc2mqtt \
            --image-tag ${lib.escapeShellArg version} \
            --quiet > "$OUT"
        '';
      };
    };
}
