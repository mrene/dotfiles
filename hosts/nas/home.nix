_: {
  flake.modules.homeManager.nas =
    { pkgs, ... }:
    {
      home.stateVersion = "20.09";

      home.username = "mrene";
      home.homeDirectory = "/home/mrene";

      home.packages = with pkgs; [
        fishPlugins.foreign-env
      ];
    };
}
