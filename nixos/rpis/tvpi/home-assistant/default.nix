{pkgs, ...}: let
  sources = pkgs.callPackage ../../../../_sources {};
  hostBasePath = "/opt/homeassistant";
  smartIr = sources.fetch "smartir";
  smartIrWithCodes = pkgs.symlinkJoin {
    name = "smartir-with-codes";
    paths = ["${smartIr}/custom_components/smartir"];
    postBuild = ''
      cp -rs ${smartIr}/codes $out/codes
      chmod 0766 $out/codes
      chmod 0766 $out/codes/climate
      cp -s ${./9999.json} $out/codes/climate/9999.json
    '';
  };
in {
  virtualisation.oci-containers.containers = {
    #homeassistant = let
      ## Inject new file as "codes/climate/9999.json"
      #customComponents = pkgs.linkFarm "custom-components" [
        #{
          #name = "smartir";
          #path = "${smartIrWithCodes}";
        #}
      #];
    #in {
      #image = sources.dockerImageUrl "homeassistant";
      #environment = {
        #TZ = "America/Montreal";
      #};
      #volumes = [
        #"${hostBasePath}/config:/config"
        #"${customComponents}:/config/custom_components"
        #"/nix/store:/nix/store:ro"
      #];
      #ports = [
        #"20810:20810"
      #];
      #extraOptions = [
        #"--network=host"
        #"--privileged"
      #];
    #};

    addon-server-matter = {
      image = sources.dockerImageUrl "python-matter-server";
      environment = {
        TZ = "America/Montreal";
      };
      volumes = [
        "${hostBasePath}/python-matter-server:/data"
        "/run/dbus:/run/dbus:ro"
      ];
      extraOptions = [
        "--network=host"
        "--privileged"
      ];
    };

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
}
