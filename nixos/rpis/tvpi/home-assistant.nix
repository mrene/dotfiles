{ lib, pkgs, common, inputs, ... }:
let
  hostBasePath = "/opt/homeassistant";
  imageName = "ghcr.io/home-assistant/home-assistant";
  imageTag = "2023.7.1";
  imageDigest = "sha256:a86ff5d05ce46520c53d67c8da55aba310de9b9b4ca8eead1ae0b5ab1c068f97";

  imageFile = pkgs.dockerTools.pullImage {
    inherit imageName imageDigest;
    finalImageName = imageName;
    finalImageTag = imageTag;
    # To update:
    # nix-prefetch-docker ghcr.io/home-assistant/home-assistant <tag>
    sha256 = "07afv3sf84vw1rfvc9l11l15gbiblmgwj80yb18ghv7w6n272zxb";
    arch = "aarch64";
  };
in
{ 
  virtualisation.oci-containers.containers = {
    homeassistant =  {
      #inherit imageFile;

      image = "${imageName}:${imageTag}@${imageDigest}";

      environment = {
        TZ = "America/Montreal";
      };
      volumes = [
        "${hostBasePath}/config:/config"
      ];
      ports = [
        "20810:20810"
      ];
      extraOptions = [
        "--network=host"
        "--privileged"
      ];
    };
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