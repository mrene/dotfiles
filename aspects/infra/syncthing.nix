_:

let
  domain = "tailc705a.ts.net";

  mkDevice =
    { id, host }:
    {
      inherit id;
      addresses = [
        "dynamic"
        "tcp://${host}.${domain}:22000"
        "quic://${host}.${domain}:22000"
      ];
    };

  sharedSettings = {
    devices = {
      # "beast" = mkDevice { id = "DEVICE-ID"; host = "beast"; };
      "mbpm3" = mkDevice { id = "YMRJF6X-Q6NAE6V-5UDGE2J-4HJYRA4-DE42KSE-CIJKHVG-3CTASBE-RIFMCQB"; host = "mrene-mbp-m3"; };
      "nas" = mkDevice { id = "FZAM63C-L35LMXT-BQKLMFI-A3ZGPGI-NWZ74I2-SAJIKW7-DWUR5IP-US52MQF"; host = "nas"; };
    };

    options = {
      urAccepted = -1;
    };
  };
in
{
  flake.aspects.infra-syncthing = {
    homeManager =
      { ... }:
      {
        services.syncthing = {
          enable = true;
          overrideDevices = true;
          overrideFolders = true;
          settings = sharedSettings;
        };
      };

    nixos =
      { ... }:
      {
        services.syncthing = {
          enable = true;
          user = "mrene";
          dataDir = "/home/mrene";
          overrideDevices = true;
          overrideFolders = true;
          settings = sharedSettings;
        };
      };
  };

  # Per-machine folder configuration
  flake.modules.homeManager.mbpm3 = _: {
    services.syncthing.settings.folders = {
      "3d-printing" = {
        path = "/Users/mrene/Documents/3d-printing";
        devices = [ "nas" ];
      };
    };
  };

  flake.modules.nixos.nas = _: {
    services.syncthing.settings.folders = {
      "3d-printing" = {
        path = "/bulk/replicated/mrene/3d-printing";
        devices = [ "mbpm3" ];
      };
    };
  };
}
