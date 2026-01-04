_:
{
  flake.aspects.services-dyndns.nixos =
    { config, ... }:
    {
      sops.secrets."cloudflare/token" = { };
      services.cloudflare-dyndns = {
        enable = true;
        apiTokenFile = config.sops.secrets."cloudflare/token".path;
        domains = [ "home.mathieurene.com" ];
        proxied = false;
        ipv4 = true;
        ipv6 = false;
      };
    };
}
