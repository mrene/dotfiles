{ lib, config, ... }:

let
  cfg = config.homelab.ssh-ca;
in
{
  options.homelab.ssh-ca = {
    enable = lib.mkEnableOption "Enable homelab SSH certificate authority configuration";
  };

  config = lib.mkIf cfg.enable {
    environment.etc."ssh/trusted-user-ca-keys.pem".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGxadtHiu72FNZY+fjEJlqj5r3YInyuAjr04/kiTw0zw";
    environment.etc."ssh/ssh_known_hosts".text = "@cert-authority *.tailc705a.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/QMECziSNuD00LieXYd/Omcf7HYdoMuZ8Bf4ch4Sn4";

    services.openssh.extraConfig = ''
      TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
    '';
  };
}
