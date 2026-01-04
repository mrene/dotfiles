_: {
  flake.modules.homeManager.utm =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        fishPlugins.foreign-env
      ];

      home.stateVersion = "20.09";
    };
}
