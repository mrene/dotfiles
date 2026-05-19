{ config, ... }:
let
  inherit (config.npins.hydroqc2mqtt) version;
in
{
  externals.hydroqc2mqtt = {
    filename = "hydroqc2mqtt.nix";
    cacheKey = version;
    producer =
      { lib, nix-prefetch-docker, ... }:
      ''
        ${lib.getExe nix-prefetch-docker} \
          --image-name registry.gitlab.com/hydroqc/hydroqc2mqtt \
          --image-tag ${lib.escapeShellArg version} \
          --quiet > "$OUT"
      '';
  };
}
