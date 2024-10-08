{
  pkgs,
  lib,
  inputs,
  ...
}: {
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # Since we patched the service to support notify in the overlay
  systemd.services.openrgb.serviceConfig.Type = "notify";

  systemd.services.openrgbprofile = {
    description = "apply openrgb profile main";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      After = ["openrgb.service"];
      ExecStart = "${lib.getExe inputs.mrene-nur.packages.${pkgs.system}.openrgb-sdnotify} -p ${./../../home-manager/modules/rgb}/default.orp";
    };
  };
}
