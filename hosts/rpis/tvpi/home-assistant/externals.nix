{
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
      externals.hydroqc2mqtt = {
        filename = "hydroqc2mqtt.nix";
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
