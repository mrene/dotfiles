{ ... }:

let
  tailscaleDNS = name: name + ".mathieu-rene.gmail.com.beta.tailscale.net";
in

{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      github = {
        hostname = "github.com";
        user = "git";
      };

      nas = {
        hostname = tailscaleDNS "truenas";
        user = "mrene";
        forwardAgent = true;
      };

      home = {
        hostname = tailscaleDNS "beast";
        user = "mrene";
        forwardAgent = true;
      };

      rpi4 = {
        hostname = tailscaleDNS "rpi4";
        user = "pi";
        forwardAgent = true;
      };

      mbp = {
        hostname = tailscaleDNS "mathieus-macbook-pro"; #Tailscale
        user = "mrene";
        forwardAgent = true;
      };
    };
  };
}
