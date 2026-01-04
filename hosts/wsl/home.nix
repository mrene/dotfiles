_: {
  flake.modules.homeManager.wsl =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        fishPlugins.foreign-env
      ];

      home.stateVersion = "20.09";
    };
}
