{
  pkgs,
  inputs,
  ...
}: let
  soapysdr = pkgs.soapysdr.override (_old: {
    extraPackages = [
      pkgs.soapybladerf
    ];
  });

  overrideSoapy = p: p.override (_old: {inherit soapysdr;});

  bedrpc = pkgs.callPackage "${inputs.bedrpc}/package.nix" {inherit soapysdr;};
in {
  environment.systemPackages = with pkgs; [
    soapysdr
    (overrideSoapy soapyremote)
    libbladeRF
    bedrpc.server
    bedrpc.cli
  ];

  systemd.services.bedrpc = {
    description = "MQTT Bed Remote";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = (lib.getExe' bedrpc "server") + " -m 127.0.0.1";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
