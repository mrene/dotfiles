{pkgs, lib, config, inputs, ...}: let
  sources = pkgs.callPackage ../../../../_sources {};
  hostBasePath = "/opt/homeassistant";
  themes = {
    catppuccin = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "home-assistant";
      rev = "e877188ca467e7bbe8991440f6b5f6b3d30347fc";
      hash = "sha256-eUqYlaXNLPfaKn3xcRm5AQwTOKf70JF8cepibBb9KXc=";
    };
  };
  joinedThemes = pkgs.symlinkJoin {
    name = "home-assistant-themes";
    paths = (builtins.map (t: "${t}/themes") (builtins.attrValues themes));
  };
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
          homekit = [
            {
              filter = {
                include_entity_globs = [
                  "climate.heat_pump"
                  "climate.nest"
                  "light.office_lamp"
                  "light.office_rgb"
                  "media_player.lg_webos_smart_tv"
                  "media_player.denon_avr_x1600h"
                  "media_player.denon_avr_x1600h_2"
                ];
              };
            }
          ];
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
              mac = "d8:bb:c1:14:45:79";
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
              command = "b64:JgB4AAABI5ESNxISEhMSExETERMSExETERMRNxI3EjcROBA4EzcRNxE3EjcRNxITERMSExETEhMRExISERMSNxE4ETcRNxI4EjcRNxI3ERMSExETEBQRExETEhQRExE3ETcTNxA4ETcRAAG1AAEjSREADDQAASJKDwANBQ=="; 
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
        configWritable = true;
        configDir = "/opt/homeassistant/config";
        extraComponents = #lib.lists.subtractLists [ "raincloud" "tensorflow" "azure_devops" "azure_event_hub" "linode" "lyric" ] config.services.home-assistant.package.passthru.availableComponents;
        [
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
          "zha"
        ];
        extraPackages = python3Packages: with python3Packages; [
          grpcio
        ];
        customComponents = with pkgs.home-assistant-custom-components; [
          smartthinq-sensors
          adaptive_lighting
          (smartir.overrideAttrs { 
            postInstall = ''
              cp -r codes $out/custom_components/smartir/
              cp -s ${./9999.json} $out/custom_components/smartir/codes/climate/9999.json
            '';
          })
          inputs.mrene-nur.packages.${pkgs.system}.connectlife-ha
          inputs.mrene-nur.packages.${pkgs.system}.openrgb-ha
        ];
        customLovelaceModules = (with pkgs.home-assistant-custom-lovelace-modules; [
          mini-graph-card
          mini-media-player
          lg-webos-remote-control
          android-tv-card
          card-mod
        ]) ++ (with inputs.mrene-nur.packages.${pkgs.system}; [
          clock-weather-card
          lovelace-auto-entities
          lovelace-slider-entity-row
          timer-bar-card
        ]);
      };

      systemd.tmpfiles.rules =  [ 
        "L+ ${config.services.home-assistant.configDir}/themes - - - - ${joinedThemes}" 
      ];

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
        logLevel = "err";
        radio =  {
          device = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231118192304-if00";
          baudRate = 460800;
          flowControl = true;
          extraDevices = [ "trel://eth0" ];
        };
        rest = {
          listenPort = 58081;
        };
        web = {
          enable = true;
          listenPort = 58082;
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


