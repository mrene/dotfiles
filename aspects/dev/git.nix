_:
{
  flake.aspects.dev-git.homeManager =
    { pkgs, ... }:
    let
      delta = pkgs.fetchFromGitHub {
        owner = "dandavison";
        repo = "delta";
        rev = "acd758f7a08df6c2ac5542a2c5a4034c664a9ed8";
        sha256 = "1f9f29sh416jxyrzhsfn3gxxfgam0mxnjsl7y5a9xsa8ipzbkn9g";
      };
    in
    {
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
