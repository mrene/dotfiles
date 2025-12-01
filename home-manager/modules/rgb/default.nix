{ lib, ... }:
{
  flake.modules.homeManager.all =
    { config, pkgs, ... }:
    let
      cfg = config.homelab.system.rgb;
      inherit (pkgs) writeShellApplication dbus openrgb;
      rgb-auto-toggle = writeShellApplication {
        name = "rgb-auto-toggle";
        text = ''
          # From https://askubuntu.com/questions/150790/how-do-i-run-a-script-on-a-dbus-signal
          interface=org.gnome.ScreenSaver
          member=ActiveChanged

          ${dbus}/bin/dbus-monitor --session --monitor "interface='$interface',member='$member'" |
          while read -r line; do
            case "$line" in
              *"boolean true"*)
                echo "Screen locked"
                ${openrgb}/bin/openrgb --profile off
                ;;
              *"boolean false"*)
                echo "Screen unlocked"
                ${openrgb}/bin/openrgb --profile default
                ;;
            esac
          done
        '';
      };
    in
    {
      options.homelab.system.rgb = {
        enable = lib.mkEnableOption "Enable RGB lighting auto-toggle on screen lock";
      };

      config = lib.mkIf cfg.enable {
        systemd.user.services.rgb-auto-toggle = {
          Unit = {
            Description = "Toggle rgb on/off when the screensaver stops/starts";
            Wants = [
              "dbus.socket"
              "openrgb.service"
            ];
          };

          Install = {
            WantedBy = [ "graphical-session.target" ];
          };

          Service = {
            ExecStart = "${lib.getExe rgb-auto-toggle}";
            Restart = "always";
            RestartSec = "5";
          };
        };
      };
    };
}
