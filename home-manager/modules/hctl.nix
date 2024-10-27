{ config, lib, pkgs, ... }:

let
  cfg = config.programs.hctl;
  yamlFormat = pkgs.formats.yaml {};
in
{
  options.programs.hctl = {
    enable = lib.mkEnableOption "hctl program";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.mrene-nur.packages.${system}.hctl;
      defaultText = lib.literalExpression "pkgs.hctl";
      description = "The hctl package to use.";
    };

    hubUrl = lib.mkOption {
      type = lib.types.str;
      description = "Home Assistant URL";
      example = "http://homeassistant.local:8123/api";
    };

    tokenSecretName = lib.mkOption {
      type = lib.types.str;
      description = ''
        Name of the sops secret containing the Home Assistant access token.
        This should match the secret name in your sops configuration.
      '';
      example = "hass-token";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1337;
      description = "Port to serve the hctl service on";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [ "debug" "info" "warning" "error" ];
      default = "error";
      description = "Logging level";
    };

    completion.shortNames = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable short names for entities";
    };

    deviceMap = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Device name mappings";
    };

    handling.fuzz = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable fuzzy matching for entity names";
    };

    mediaMap = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Media name mappings";
    };

    serveIp = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "IP address to bind the service to. Empty string for all interfaces.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    sops.secrets.${cfg.tokenSecretName} = {};

    sops.templates."hctl.yaml".content = yamlFormat.generate "hctl-config" {
      completion.short_names = cfg.completion.shortNames;
      device_map = cfg.deviceMap;
      handling.fuzz = cfg.handling.fuzz;
      hub = {
        type = "hass";
        url = cfg.hubUrl;
        token = config.sops.placeholder.${cfg.tokenSecretName};
      };
      logging.log_level = cfg.logLevel;
      media_map = cfg.mediaMap;
      serve = {
        ip = cfg.serveIp;
        port = cfg.port;
      };
    };

    xdg.configFile."hctl/hctl.yaml".source = config.sops.templates."hctl.yaml".path;
  };
}