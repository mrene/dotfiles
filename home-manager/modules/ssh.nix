_: let
  tailscaleDNS = name: name + ".tailc705a.ts.net";
in {
  programs.ssh = {
    enable = true;

    matchBlocks = {
      github = {
        hostname = "github.com";
        user = "git";
      };

      nas = {
        hostname = tailscaleDNS "nas";
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
        hostname = tailscaleDNS "mathieus-macbook-pro";
        user = "mrene";
        forwardAgent = true;
      };
    };
  };
}
