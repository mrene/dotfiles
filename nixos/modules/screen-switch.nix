
{ config, lib, pkgs, ... }:

let
  cfg = config.homelab.screen-input-switcher;
in
{
  options.homelab.screen-input-switcher = {
    enable = lib.mkEnableOption "automatically switch the screen's input based on the presence of a USB device";
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="05e3", ATTRS{idProduct}=="0626", TAG+="systemd", ENV{SYSTEMD_WANTS}="screen-input-switch-add.service"
ACTION=="remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="05e3", ATTRS{idProduct}=="0626", RUN+="${pkgs.systemd}/bin/systemctl start screen-input-switch-remove.service"
'';

    # Create separate services for add and remove events with hardcoded ACTION values
    systemd.services."screen-input-switch-add" = {
      description = "Switch screen input to DisplayPort when the USB switch is connected";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "screen-input-switcher-add" ''
          echo "Switching to DisplayPort input (0x00D0)"
          ${lib.getExe pkgs.ddcutil} setvcp xF4 x00D0 --i2c-source-addr=x50 --noverify
        '';
      };
    };
    
    systemd.services."screen-input-switch-remove" = {
      description = "Switch screen input to USB-C when the USB switch is disconnected";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "screen-input-switcher-remove" ''
          echo "Switching to USB-C input (0x00D1)"
          ${lib.getExe pkgs.ddcutil} setvcp xF4 x00D1 --i2c-source-addr=x50 --noverify
        '';
      };
    };
  };
}
