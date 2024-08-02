{ lib, pkgs, inputs, ... }: 

{
  imports = [
    inputs.bedrpc.nixosModules.default
  ];

  services.bedrpc = {
    enable = true;
    mqtt = "127.0.0.1";
    mqttPort = 1883;
  };
}
