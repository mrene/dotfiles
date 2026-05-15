_:
{
  flake.aspects.shell-ghostty.homeManager =
    { ... }:
    {
      programs.ghostty = {
        enable = true;
        enableFishIntegration = true;

        settings = {
          font-family = "FiraCode Nerd Font Mono";
          theme = "catppuccin-mocha";
        };
      };
    };
}
