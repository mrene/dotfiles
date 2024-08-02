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

      # Backed up via /opt/homeassistant below
    }

    # Home Assistant Core
    {
      services.home-assistant = {
        enable = true;
        config = {
          default_config = {};
          automation = "!include automations.yaml";
          scene = "!include scenes.yaml";
          frontend = {
            themes = "!include_dir_merge_named themes";
          };
          homeassistant = {
            latitude = 45.475320;
            longitude = -73.562210; 
          };
          smartir = {};
          climate = [{
              platform = "smartir";
              name = "Heat pump";
              unique_id = "heat_pump";
              device_code = "9999";
              controller_data = "remote.2nd_floor_ir";
              temperature_sensor = "sensor.2nd_floor_ir_temperature";
              humidity_sensor = "sensor.2nd_floor_ir_humidity";
            }];
          wake_on_lan = {};
          switch = [
            {
              platform = "wake_on_lan";
              mac = "1c:fd:08:7e:19:59";
              name = "beast";
            }
            {
              platform ="wake_on_lan";
              mac ="64:E4:A5:E2:38:F4";
              name = "tv";
            }
          ];
          script = let 
            makeIrScript = { entity ? "remote.2nd_floor_ir", command }: {
              sequence = [
                  {
                    service = "remote.send_command";
                    target = {
                      entity_id = entity;
                    };
                    data = {
                      inherit command;
                    };
                  }
              ];
            };
          in          
          {
            fan_power = makeIrScript { 
              command = "b64:JgB4AAABIpIQOBMTERMSEhISEhITEhISEhISNxI3EjcROBA4ETgSNxE3ETgSExISEhISExETERQRExETETcSNxM3EDgSNxE3ETgSNhIUERMRExITERMRExETEhMRNxI3EDkSNxE4ETcSAAG0AAEjSRIADDcAASFKEgANBQ=="; 
            };
            fan_speed = makeIrScript { 
              command = "b64:JgB4AAABI5EROBETERMSFBETERMRExITERMSNhI3ETcSOBI3ETcRNxI3ETgQFQ8VEjcRExETERMSEhITEjYROBITEjcRNxE3ETgSNhITEhMSNhISExISEhISEhITNhE4ERQRNxI3ETgRAAG0AAEjSREADDIAASNJEQANBQ=="; 
            };
            fan_rotate = makeIrScript { 
              command = "b64:JgB4AAABI5EROBETERMSFBETERMRExITERMSNhI3ETcSOBI3ETcRNxI3ETgQFQ8VEjcRExETERMSEhITEjYROBITEjcRNxE3ETgSNhITEhMSNhISExISEhISEhITNhE4ERQRNxI3ETgRAAG0AAEjSREADDIAASNJEQANBQ=="; 
            };
            fan_timer = makeIrScript {
              command = "b64:JgB4AAABIZMRNxISEhITEhISEhISEhIUEhIROBA4ETcSNxI3ETgRNxM3ETcQFBE3EhISFBISEhISEhMSEjYSEhI3ETgROBI2EjcRNxITETcSEhISEhQQFBISEhISNxETETgRNxE4EjcSAAG0AAEhShEADDIAASJKEQANBQ==";
            };
            fan_pattern = makeIrScript {
              command = "b64:JgBwAAABIZMPOhAUEBQRExEUEBQRExETERQQORA4ETgROBE4EDcSOBE4ETcROBE4EBQRExAUERQQFBEVDxQRExI3ETgRNxE3ETkQORE4ETcRExAUEhMRExETERMQFhETEDgROBA4EjgQAAG1AAEiShEADQU=";
            };
          };
        };
        configWritable = false;
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
          "bluetooth"
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
        customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
          mini-graph-card
          mini-media-player
          lg-webos-remote-control
          android-tv-card
        ];
      };

      systemd.tmpfiles.rules = let 
          lcars = (pkgs.fetchFromGitHub {
            owner = "th3jesta";
            repo = "ha-lcars";
            rev = "9c7b06590a0007566ad69ba163596e7108b89f7e";
            hash = "sha256-XGoBjtVM1qloWu6kllVdiGuErGAid9j8jcbQE7nbCAg=";
          }) + "/themes";

          themes = pkgs.symlinkJoin {
            name = "home-assistant-themes";
            paths = [ lcars ];
          };
        in
        [ "L+ '${themes}' - - - - '${config.services.home-assistant.configDir}/themes}'" ];

      homelab.backups.paths = [ hostBasePath ];
    }

    {
      services.matter-server = {
        enable = true;
        logLevel = "info";
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


