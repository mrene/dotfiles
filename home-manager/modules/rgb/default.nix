{ pkgs, ... }:

let
  inherit (pkgs) lib writeShellApplication dbus openrgb;
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
            ${openrgb}/bin/openrgb --profile ${./.}/off.orp
            ;;
          *"boolean false"*)
            echo "Screen unlocked"
            ${openrgb}/bin/openrgb --profile ${./.}/default.orp
            ;;
        esac
      done
    '';
  };
in

{
  systemd.user.services.rgb-auto-toggle = {
    Unit = {
      Description = "Toggle rgb on/off when the screensaver stops/starts";
      Wants = [ "dbus.socket" "openrgb.service" ];
    };

    Service = {
      ExecStart = "${lib.getExe rgb-auto-toggle}";
      Restart = "always";
      RestartSec = "5";
    };
  };
}
