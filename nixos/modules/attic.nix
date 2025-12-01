{ lib, ... }:
{
  flake.nixosModules.all =
    {
      config,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.homelab.attic;
    in
    {
      imports = [
        # inputs.attic.nixosModules.atticd
      ];

      options.homelab.attic = {
        enable = lib.mkEnableOption "Enable homelab attic configuration";
        domain = lib.mkOption {
          type = lib.types.str;
          default = "nixcache.mathieurene.com";
          description = "The domain to use for the attic service";
        };
      };

      config = lib.mkIf cfg.enable {
        sops.secrets = {
          "attic/hs256_secret" = { };
        };

        services.atticd = {
          enable = true;
          environmentFile = config.sops.secrets."attic/hs256_secret".path;
          package = pkgs.attic-server;

          settings = {
            listen = "[::]:8080";
            # Chunking settings from their nixos deployment guide
            # https://docs.attic.rs/admin-guide/deployment/nixos.html
            chunking = {
              # The minimum NAR size to trigger chunking
              #
              # If 0, chunking is disabled entirely for newly-uploaded NARs.
              # If 1, all NARs are chunked.
              nar-size-threshold = 64 * 1024; # 64 KiB

              # The preferred minimum size of a chunk, in bytes
              min-size = 16 * 1024; # 16 KiB

              # The preferred average size of a chunk, in bytes
              avg-size = 64 * 1024; # 64 KiB

              # The preferred maximum size of a chunk, in bytes
              max-size = 256 * 1024; # 256 KiB
            };
          };
        };

        services.caddy.virtualHosts."${cfg.domain}" = lib.mkIf config.services.caddy.enable {
          extraConfig = ''
            reverse_proxy http://localhost:8080
          '';
        };
      };
    };
}
