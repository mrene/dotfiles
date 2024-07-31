{pkgs, lib, config, ...}: let
  sources = pkgs.callPackage ../../../../_sources {};
  hostBasePath = "/opt/homeassistant";
in 
  lib.mkMerge [
    # Hydro Quebec Usage Importer
    {
      virtualisation.oci-containers.containers = {
        hydroqc2mqtt = {
          image = sources.dockerImageUrl "hydroqc2mqtt";
          environment = {
            TZ = "America/Montreal";
            CONFIG_YAML = "/config/config.yaml"; # contains secrets, only deployed on device
          };
          volumes = [
            "${hostBasePath}/hydroqc2mqtt:/config"
          ];
          extraOptions = [
            "--network=host"
          ];
        };
      };

      # Bakced up via /opt/homeassistant below
    }

    # Home Assistant Core
    {
      services.home-assistant = {
        enable = true;
        config = null;
        configWritable = true;
        configDir = "/opt/homeassistant/config";
        extraComponents = [
          "default_config"
          "met"
          "esphome"
          "rpi_power"
          "homekit_controller"
          "dhcp"
          "stream"
          "mobile_app"
          "heos"
          "thread"
          "environment_canada"
          "vesync"
          "otbr"
          "webostv"
          "denonavr"
          "tailscale"
          "tuya"
          "apple_tv"
          "influxdb"
          "upnp"
          "cast"
          "homekit"
          "wake_on_lan"
          "nest"
          "spotify"
          "homeassistant_sky_connect"
          "unifiprotect" # not used but it complains about the uiprotect python package
        ];
        extraPackages = python3Packages: with python3Packages; [
          grpcio
        ];
        customComponents = with pkgs.home-assistant-custom-components; [
          (smartir.overrideAttrs { 
            postInstall = ''
              cp -r codes $out/custom_components/smartir/
              cp -s ${./9999.json} $out/custom_components/smartir/codes/climate/9999.json
            '';
          })
        ];
      };

      homelab.backups.paths = [ hostBasePath ];
    }

    {
      services.matter-server = {
        enable = true;
        logLevel = "info";
        #extraArgs = [ "--paa-root-cert-dir" "/var/lib/matter-server/credentials" ];
      };

      # Override the launch params because "--vendorid 4939" prevents it from starting
      # when using our config ported from the docker container
      systemd.services.matter-server.serviceConfig.ExecStart = let 
        mcfg = config.services.matter-server;
        storagePath = "/var/lib/matter-server";
      in
      lib.mkForce (lib.concatStringsSep " " [ 
        (lib.getExe pkgs.python-matter-server)
        "--log-level" mcfg.logLevel
        "--port" (toString mcfg.port)
        "--storage-path" storagePath
        "--paa-root-cert-dir" "${storagePath}/credentials"
        (lib.escapeShellArgs mcfg.extraArgs)
      ]);

      # Backup its storage state
      homelab.backups.paths = [ "/var/lib/matter-server" ];
    }

    {
      services.openthread-border-router = {
        enable = true;
        backboneInterface = "eth0";
        logLevel = 3;
        radio =  {
          device = "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_a8cf5592bed8ed1198a76f6162c613ac-if00-port0";
          baudRate = 460800;
          flowControl = true;
        };
        rest = {
          listenPort = 58081;
        };
      };

      # Backup thread netdata (includes network credentials (aka "dataset"))
      homelab.backups.paths = [ "/var/lib/thread" ];
    }
    {
      services.mosquitto = {
        enable = true;
        listeners = [
          {
            acl = ["pattern readwrite #"];
            omitPasswordAuth = true;
            settings.allow_anonymous = true;
          }
        ];
      };
      # Backup internal state
      homelab.backups.paths = [ "/var/lib/mosquitto" ];
    }
  ]
  # services.influxdb2.enable = true;
  # services.grafana = {
  #   enable = true;
  #   settings = {
  #     server = {
  #       http_addr = "0.0.0.0";
  #       http_port = 8087;
  #       domain = "192.168.1.245:8087";
  #       root_url = "http://192.168.1.245:8087";
  #     };
  #   };
  # };

