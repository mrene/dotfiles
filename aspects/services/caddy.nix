_:
{
  flake.aspects.services-caddy.nixos = _: {
    services.caddy = {
      enable = true;
      email = "mathieu.rene@gmail.com";
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
