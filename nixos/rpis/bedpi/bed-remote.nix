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
}
