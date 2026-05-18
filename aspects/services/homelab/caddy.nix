_: {
  flake.modules.nixos.services-homelab = {
    services.caddy = {
      enable = true;
      email = "mathieu.rene@gmail.com";
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
