{ pkgs, ... }:
{
  virtualisation.oci-containers.containers = {
    homeassistant = 
      let
        hostBasePath = "/opt/homeassistant";
        imageName = "ghcr.io/home-assistant/home-assistant";
        imageTag = "2023.11.3";
        imageDigest = "sha256:feffc0b8227dbbf9d1bf61c465ff54b24aff2c990a1e54ea7219c4b300260ef9";

        smartIr = pkgs.fetchFromGitHub {
          owner = "smartHomeHub";
          repo = "SmartIR";
          rev = "b0b4bc8ab88a2d76f7dc7a650c8beb00f638ceff";
          hash = "sha256-HlvWZ12aXZDa3tgaOgKnTcQCnr0l0Pc1GcxWj0oQYpQ=";

          # TODO: Patch with our IR codes
        };

        customComponents = pkgs.linkFarm {
          name = "custom-components";
          paths = [
            { name =  "smartir"; path = "${smartIr}"; }
          ];
        };
      in {
        image = "${imageName}:${imageTag}@${imageDigest}";

        environment = {
          TZ = "America/Montreal";
        };
        volumes = [
          "${hostBasePath}/config:/config"
          "${customComponents}:/config/custom_components"
          "/nix/store:/nix/store:ro"
        ];
        ports = [
          "20810:20810"
        ];
        extraOptions = [
          "--network=host"
          "--privileged"
        ];
    };

    addon-server-matter = 
      let
        hostBasePath = "/opt/homeassistant";
        imageName = "ghcr.io/home-assistant-libs/python-matter-server";
        imageTag = "4.0.2";
        imageDigest = "sha256:f56613284edb88284282364ce969b40ae26c0385e01b90368decff0ec742db24";
      in {
        image = "${imageName}:${imageTag}@${imageDigest}";

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
  };

  services.mosquitto = {
    enable = true;
  };

  services.influxdb2.enable = true;
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 8087;
        domain = "192.168.1.245:8087";
        root_url = "http://192.168.1.245:8087";
      };
    };
  };
}
