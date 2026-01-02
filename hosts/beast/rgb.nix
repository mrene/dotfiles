_: {
  flake.modules.nixos.beast = _: {
    services.hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };
}
