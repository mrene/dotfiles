{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.homelab.dev.git;
  delta = pkgs.fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    rev = "ac396c3fdc5940c724e1f00a519358c27979b539";
    sha256 = "1prmwm1v9sdrlb7yxhq07bdssdn7s3hgx9xh23f2f58nqw83bf17";
  };
in
{
  options.homelab.dev.git = {
    enable = lib.mkEnableOption "Enable git configuration with delta";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user = {
          name = "Mathieu Rene";
          email = "mathieu.rene@gmail.com";
        };

        github.user = "mrene";
        push.autoSetupRemote = true;

        core = {
          editor = "nvim";
          fileMode = false;
          ignorecase = false;
        };

        include = {
          path = "${./delta}/themes.gitconfig";
        };
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true; # N to switch files
        syntax-theme = "Nord";
        side-by-side = false;
        features = "chameleon-mod";
      };
    };
  };
}
