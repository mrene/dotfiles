{ lib, config, pkgs, inputs,  ... }:


let
  cfg = config.homelab.backups;
in
{
  options.homelab.backups = {
    enable = lib.mkEnableOption "Enable homelab backups configuration";
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Paths to backup";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "restic/environment" = {};
      "restic/repository" = {};
      "restic/password" = {};
    };

    services.restic.backups = {
      daily = {
        initialize = true;
        environmentFile = config.sops.secrets."restic/environment".path;
        repositoryFile = config.sops.secrets."restic/repository".path;
        passwordFile = config.sops.secrets."restic/password".path;

        # Paths are being added by respective modules
        paths = cfg.paths;

        pruneOpts = [
          "--keep-daily=7"
          "--keep-weekly=5"
          "--keep-monthly=3"
        ];
      };
    };
  };
}
