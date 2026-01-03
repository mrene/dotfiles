{ lib, ... }:
let
  # Shared module for both NixOS and Darwin
  mkTailscaleNetworkingModule =
    { config, ... }:
    let
      cfg = config.homelab.tailscale-networking;
    in
    {
      options.homelab.tailscale-networking = {
        enable = lib.mkEnableOption "Use Tailscale MagicDNS hostname for clan networking";
        user = lib.mkOption {
          type = lib.types.str;
          default = "root";
          description = "SSH user for clan deployment";
        };
      };

      config = lib.mkIf cfg.enable {
        clan.core.networking.targetHost = "${cfg.user}@${config.networking.hostName}";
      };
    };
in
{
  flake.aspects.infra-tailscale-networking = {
    nixos = mkTailscaleNetworkingModule;
    darwin = mkTailscaleNetworkingModule;
  };
}
