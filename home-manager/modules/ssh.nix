{ ... }:

{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      github = {
        hostname = "github.com";
        user = "git";
      };

      nas = {
        hostname = "100.76.135.41"; #Tailscale
        user = "mrene";
      };

      home = {
        hostname = "100.95.58.37"; #Tailscale
        user = "mrene";
      };

      rpi4 = {
        hostname = "100.80.33.33"; #Tailscale
        user = "pi";
      };

      mbp = {
        hostname = "100.72.62.35"; #Tailscale
        user = "mrene";
      };
    };
  };
}
