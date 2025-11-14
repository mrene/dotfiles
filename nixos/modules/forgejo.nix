{ lib, config, ... }:

{
  options = {
    homelab.forgejo = {
      enable = lib.mkEnableOption "forgejo";
    };
  };

  config = let 
    cfg = config.homelab.forgejo;
  in lib.mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      lfs.enable = true;
      settings.server = {
        HTTP_PORT = 30123;
        DOMAIN = config.networking.hostName;
      };
    };

    homelab.backups.paths = [ config.services.forgejo.stateDir ];
  };
}
