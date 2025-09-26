_: let
  tailscaleDNS = name: name + ".tailc705a.ts.net";
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        # Default SSH configuration
        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts ~/.ssh/known_hosts2";
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "10m";
      };

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
