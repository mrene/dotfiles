_:
{
  flake.modules.nixos.services-homelab = _: {
    services.caddy = {
      enable = true;
      email = "mathieu.rene@gmail.com";
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
