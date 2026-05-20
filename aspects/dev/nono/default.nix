{ lib, ... }:
{
  flake.aspects.dev.homeManager =
    { pkgs, config, ... }:
    let
      cfg = config.dotfiles.nono;
    in
    {
      options.dotfiles.nono = {
        profiles = lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
          default = { };
          description = "Nono profiles, keyed by profile name. Each value is rendered to ~/.config/nono/profiles/<name>.json. The attrset key is auto-injected as meta.name.";
        };
      };

      config = {
        home.file = lib.mapAttrs' (
          name: profile:
          lib.nameValuePair ".config/nono/profiles/${name}.json" {
            source = pkgs.writers.writeJSON "nono-profile-${name}.json" (
              profile
              // {
                meta = (profile.meta or { }) // {
                  name = name;
                };
              }
            );
          }
        ) cfg.profiles;

        home.packages = [
          pkgs.nono
        ];

        dotfiles.nono.profiles.coding-agent = {
          meta.version = "1.0.0";
          workdir.access = "readwrite";
          filesystem = {
            read = [
              "/proc"
              "/nix"

              "$HOME/dotfiles"

              "$HOME/.config/git"
              "$HOME/.gitignore"

              "$HOME/.nix-profile/bin"
              "$HOME/.local/state/nix"
              "$HOME/.local/share/nix"
              "$HOME/.nix-defexpr"
            ];
            allow = [
              "$HOME/.config/jj"

              "$HOME/.config/fish"
              "$HOME/.local/share/fish"

              "$HOME/.cache/nix"

              "$HOME/.cache/go-build"
              "$HOME/.cache/golangci-lint"

              "$HOME/.npm"

              "/tmp"
            ];
            read_file = [ "$HOME/.profile" ];
            write_file = [ ];
          };
        };
      };
    };
}
