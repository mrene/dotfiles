{ lib, ... }:
{
  flake.nixosModules.all =
    { config, ... }:
    let
      cfg = config.homelab.forgejo;
    in
    {
      options = {
        homelab.forgejo = {
          enable = lib.mkEnableOption "forgejo";
        };
      };

      config = lib.mkIf cfg.enable {
        services.forgejo = {
          enable = true;
          lfs.enable = true;

          settings.service.DISABLE_REGISTRATION = true;
          settings.server = {
            HTTP_PORT = 30123;
            SSH_PORT = lib.head config.services.openssh.ports;
            DOMAIN = config.networking.hostName;
          };
        };
        services.openssh.settings.AcceptEnv = "GIT_PROTOCOL";

        homelab.backups.paths = [ config.services.forgejo.stateDir ];
      };
    };
}
