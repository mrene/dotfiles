{ lib, ... }:
{
  flake.modules.homeManager.all =
    {
      config,
      pkgs,
      osConfig,
      ...
    }:
    let
      cfg = config.homelab.shell.fish;

      version = "unstable-2025-12-19";

      src = pkgs.fetchFromGitHub {
        owner = "Realiserad";
        repo = "fish-ai";
        rev = "d47357c5bd78563737c31f8b6c5fee9dff73197d";
        sha256 = "1n3cw363qvlp917hrvn55h4njxnps79vv4lc06bwmcbqr0frg844";
      };

      python = pkgs.python312;
      pythonPackages = pkgs.python312Packages;

      # Patch iterfzf to use system fzf instead of bundled (which doesn't exist in nixpkgs)
      iterfzf = pythonPackages.iterfzf.overridePythonAttrs (old: {
        doCheck = false; # Fails on MacOS
        postPatch = (old.postPatch or "") + ''
          substituteInPlace iterfzf/__init__.py \
            --replace-fail "Path(__file__).parent / EXECUTABLE_NAME" "None"
        '';
      });

      # Build fish-ai as a Python package
      fishAiPython = pythonPackages.buildPythonApplication {
        pname = "fish-ai";
        inherit version src;
        pyproject = true;

        build-system = [ pythonPackages.setuptools ];

        dependencies =
          with pythonPackages;
          [
            openai
            anthropic
            keyring
            groq
            cohere
            binaryornot
            google-genai
            simple-term-menu
          ]
          ++ [ iterfzf ];

        # Skip tests - they require network
        doCheck = false;

        # Skip runtime deps check - nixpkgs versions are close enough
        dontCheckRuntimeDeps = true;
      };

      # Create a venv-like structure that fish-ai expects at ~/.local/share/fish-ai
      fishAiEnv = pkgs.runCommand "fish-ai-env" { } ''
        mkdir -p $out/bin

        # Link all entry point scripts from fish-ai
        for f in ${fishAiPython}/bin/*; do
          ln -s "$f" "$out/bin/$(basename "$f")"
        done

        # Link python3 for compatibility
        ln -sf ${python}/bin/python3 $out/bin/python3
      '';

      # Fish plugin
      fishAiPlugin = pkgs.fishPlugins.buildFishPlugin {
        pname = "fish-ai";
        inherit version src;
      };
    in
    {
      config = lib.mkIf cfg.enable {
        # Deploy fish-ai data files to ~/.local/share/fish-ai
        xdg.dataFile."fish-ai".source = fishAiEnv;

        programs.fish = {
          plugins = [
            {
              name = "fish-ai";
              src = fishAiPlugin.src;
            }
          ];

          # Fish AI bindings (don't work in vi mode by default)
          interactiveShellInit = ''
            bind -M insert ctrl-p _fish_ai_codify_or_explain
            bind -M insert ctrl-alt-space _fish_ai_autocomplete_or_fix
          '';
        };

        # sops.templates."fish-ai.ini" = {
        #   content = /* ini */ ''
        #     [anthropic]
        #     provider = anthropic
        #     api_key = ${osConfig.sops.placeholder.anthropic.api_key}
        #   '';
        #   path = "${config.xdg.configHome}/fish-ai.ini";
        # };
      };
    };
}
