flakeParts@{ ... }:
{
  flake.modules.nixos.tvpi =
    {
      pkgs,
      lib,
      config,
      inputs,
      ...
    }:
    let
      npins = flakeParts.config.npins;
      hydroqc2mqttImage = pkgs.dockerTools.pullImage flakeParts.config.externals.hydroqc2mqtt.nixValue;
      hostBasePath = "/opt/homeassistant";
      themes = {
        catppuccin = npins.catppuccin-home-assistant;
      };
      joinedThemes = pkgs.symlinkJoin {
        name = "home-assistant-themes";
        paths = (map (t: "${t}/themes") (builtins.attrValues themes));
      };
    in
    lib.mkMerge [
      # Hydro Quebec Usage Importer
      {
        virtualisation.oci-containers.containers = {
          hydroqc2mqtt = {
            image = hydroqc2mqttImage.sourceURL;
            environment = {
              TZ = "America/Montreal";
              CONFIG_YAML = "/config/config.yaml";
            };
            volumes = [
              "${hostBasePath}/hydroqc2mqtt:/config"
            ];
            extraOptions = [
              "--network=host"
            ];
          };
        };
      }

      # Home Assistant Core
      {
        services.home-assistant = {
          enable = true;
          config = {
            default_config = { };
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
                    "fan.iqair_fan"
                    "light.office_lamp"
                    "light.office_rgb"
                  ];
                };
              }
            ];
            smartir = { };
            climate = [
              {
                platform = "smartir";
                name = "Heat pump";
                unique_id = "heat_pump";
                device_code = "9999";
                controller_data = "remote.2nd_floor_ir";
                temperature_sensor = "sensor.2nd_floor_ir_temperature";
                humidity_sensor = "sensor.2nd_floor_ir_humidity";
              }
            ];
            wake_on_lan = { };
            switch = [
              {
                platform = "wake_on_lan";
                mac = "d8:bb:c1:14:45:79";
                name = "beast";
              }
              {
                platform = "wake_on_lan";
                mac = "64:E4:A5:E2:38:F4";
                name = "tv";
              }
            ];
            "script ha" = "!include scripts.yaml";
            script =
              let
                makeIrScript =
                  {
                    entity ? "remote.2nd_floor_ir",
                    command,
                  }:
                  {
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
            "unifiprotect"
            "bluetooth"
            "zha"
            "broadlink"
            "airvisual"
            "openrgb"
            "wled"
            "lg_thinq"
          ];
          extraPackages =
            python3Packages: with python3Packages; [
              grpcio
            ];
          customComponents = with pkgs.home-assistant-custom-components; [
            smartthinq-sensors
            adaptive_lighting
            (smartir.overrideAttrs {
              version = npins.smartir.version;
              src = npins.smartir;
              patches = [ ./smartir-remove-distutils.diff ];
              postInstall = ''
                cp -r codes $out/custom_components/smartir/
                cp -s ${./9999.json} $out/custom_components/smartir/codes/climate/9999.json
                cp -s ${./9998.json} $out/custom_components/smartir/codes/fan/9998.json
              '';
            })
            inputs.mrene-nur.packages.${pkgs.stdenv.hostPlatform.system}.connectlife-ha
            inputs.mrene-nur.packages.${pkgs.stdenv.hostPlatform.system}.ha-bambulab
          ];
          customLovelaceModules =
            (with pkgs.home-assistant-custom-lovelace-modules; [
              mini-graph-card
              mini-media-player
              lg-webos-remote-control
              universal-remote-card
              card-mod
            ])
            ++ (with inputs.mrene-nur.packages.${pkgs.stdenv.hostPlatform.system}; [
              clock-weather-card
              lovelace-auto-entities
              lovelace-slider-entity-row
              timer-bar-card
              lovelace-mushroom
              ha-bambulab.cards
            ]);
        };

        systemd.tmpfiles.rules = [
          "L+ ${config.services.home-assistant.configDir}/themes - - - - ${joinedThemes}"
        ];

        homelab.backups.paths = [ hostBasePath ];
      }

      {
        services.matter-server = {
          enable = true;
          logLevel = "info";
          # Existing fabric in /var/lib/matter-server was registered under
          # the Matter test vendor 0xFFF1 (65521). The upstream module
          # defaults to the home-assistant vendor 4939, which causes a
          # fabricId=1 collision on load.
          extraArgs.vendorid = 65521;
        };

        homelab.backups.paths = [
          "/var/lib/matter-server"
          "/var/lib/private/matter-server"
        ];
      }

      {
        services.openthread-border-router = {
          enable = true;
          backboneInterfaces = [ "eth0" ];
          logLevel = "err";
          radio = {
            device = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231118192304-if00";
            baudRate = 460800;
            flowControl = true;
            extraDevices = [ "trel://eth0" ];
          };
          rest = {
            listenAddress = "0.0.0.0";
            listenPort = 8081;
          };
          web = {
            enable = true;
            listenAddress = "0.0.0.0";
            listenPort = 8082;
          };
        };

        homelab.backups.paths = [ "/var/lib/thread" ];
      }
      {
        services.mosquitto = {
          enable = true;
          listeners = [
            {
              acl = [ "pattern readwrite #" ];
              omitPasswordAuth = true;
              settings.allow_anonymous = true;
            }
          ];
        };
        homelab.backups.paths = [ "/var/lib/mosquitto" ];
      }
    ];
}
