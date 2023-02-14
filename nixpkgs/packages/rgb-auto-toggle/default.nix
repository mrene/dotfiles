{ lib, writeShellApplication, bash, dbus, openrgb }:

writeShellApplication {
  name = "rgb-auto-toggle";

  text = ''
    # From https://askubuntu.com/questions/150790/how-do-i-run-a-script-on-a-dbus-signal
    interface=org.gnome.ScreenSaver
    member=ActiveChanged

    # listen for playingUriChanged DBus events,
    # each time we enter the loop, we just got an event
    # so handle the event, e.g. by printing the artist and title
    # see rhythmbox-client --print-playing-format for more output options
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
}
