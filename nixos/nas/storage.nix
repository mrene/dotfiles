_: {
  boot = {
    supportedFilesystems = ["zfs"];
    zfs = {
      forceImportRoot = false;
      extraPools = ["bulk"];
    };
  };

  # Write /etc/crypttab manually because initrd.luks.devices tries to do everything in initrd/stage1 when the root fs isn't yet available
  # systemd appears to watch /etc/crypttab and create devices dynamically whenever required
  environment.etc.crypttab = {
    enable = true;
    text = ''
      # <target name> <source device>         <key file>      <options>
      seagate1 UUID=99f8f9b3-02ae-4dee-80ac-234bb52bdfa7 /var/secrets/bulk.key
      seagate2 UUID=0f4760fb-674e-4870-8443-ea484bca700f /var/secrets/bulk.key
    '';
  };
}
