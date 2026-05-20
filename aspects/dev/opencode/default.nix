{ inputs, lib, ... }:

{

  flake.aspects.dev.homeManager =
    { pkgs, config, ... }:
    let
      dotfilesPath = "${config.home.homeDirectory}/nixworld/dotfiles";

      mkOpencodeConfSymlinks =
        paths:
        lib.listToAttrs (
          map (path: {
            name = ".config/opencode/${path}";
            value = {
              source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/aspects/dev/opencode/${path}";
            };
          }) paths
        );

      mkSharedConfSymlinks =
        destPrefix: paths:
        lib.listToAttrs (
          map (path: {
            name = "${destPrefix}/${path}";
            value = {
              source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/aspects/dev/llm/shared/${path}";
            };
          }) paths
        );

      baseConfig = {
        "$schema" = "https://opencode.ai/config.json";

        autoupdate = false;
        shell = "fish";

        instructions = [
          "~/.config/opencode/docs/*.md"
        ];

        agent = {
          bigbrain = {
            mode = "subagent";
            model = "openai/gpt-5.5";
            description = "To be used for complex tasks (similar to opus)";
          };
          normal = {
            mode = "subagent";
            model = "opencode-go/deepseek-v4-pro";
            description = "To be used for general tasks (similar to sonnet)";
          };
          lightweight = {
            mode = "subagent";
            model = "opencode-go/deepseek-v4-flash";
            description = "To be used for lightweight tasks (similar to haiku)";
          };
        };

        permission = {
          external_directory = {
            "~/.claude/**" = "allow";
            "~/.cache/**" = "allow";
            "~/.cargo/**" = "allow";
            "~/.npm/**" = "allow";
            "~/go/**" = "allow";
            "~/dotfiles/**" = "allow";
            "/tmp/**" = "allow";
            "~/.config/jj/repos/**" = "allow";
          };
          skill = {
            "*" = "ask";
            ctx-load = "allow";
            ctx-save = "allow";
            mem-editing = "allow";
            proj-editing = "allow";
          };
        };
      };

      mainConfig = lib.recursiveUpdate baseConfig {
        permission = {
          "*" = "ask";
          read = "allow";
          edit = "allow";
          grep = "allow";
          bash = {
            "*" = "ask";
            "notify *" = "allow";
            "lsof *" = "allow";
            "readlink *" = "allow";
            "echo *" = "allow";
            "grep *" = "allow";
            "rg *" = "allow";
            "sed *" = "allow";
            "cat *" = "allow";
            "ls *" = "allow";
            "tail *" = "allow";
            "ln -s * proj" = "allow";
            "claude-proj-docs *" = "allow";
            "jj log *" = "allow";
            "jj show *" = "allow";
            "jj diff *" = "allow";
            "jj status *" = "allow";
            "jj commit *" = "allow";
            "jj new *" = "allow";
            "jj squash *" = "allow";
            "jj ls" = "allow";
            "jj st" = "allow";
            "jj file show *" = "allow";
            "jj op log *" = "allow";
            "jj describe *" = "allow";
            "jj-main-branch *" = "allow";
            "jj-current-branch *" = "allow";
            "jj-prev-branch *" = "allow";
            "jj-stacked-branches *" = "allow";
            "jj-diff-working *" = "allow";
            "jj-diff-branch *" = "allow";
            "jj-stacked-stats *" = "allow";
            "gh pr list *" = "allow";
            "gh pr view *" = "allow";
            "gh pr checks *" = "allow";
            "gh pr diff *" = "allow";
            "gh pr review *" = "allow";
            "nix eval *" = "allow";
            "nix build *" = "allow";
            "nix flake *" = "allow";
            "nix develop *" = "allow";
            "nix run *" = "allow";
            "nix shell *" = "allow";
            "nix repl *" = "allow";
            "cargo test *" = "allow";
            "cargo check *" = "allow";
            "cargo clippy *" = "allow";
            "cargo fmt *" = "allow";
            "cargo build *" = "allow";
            "cargo tree *" = "allow";
            "go build *" = "allow";
            "go fmt *" = "allow";
            "go mod *" = "allow";
            "go test *" = "allow";
            "go doc *" = "allow";
            "go vet *" = "allow";
            "gofmt *" = "allow";
            "goimports *" = "allow";
            "staticcheck *" = "allow";
            "npm run build *" = "allow";
            "npm run lint *" = "allow";
            "npm run test *" = "allow";
            "npm run fmt *" = "allow";
          };
          webfetch = "ask";
          websearch = "allow";
        };
      };
      opencodeJson = pkgs.writers.writeJSON "opencode.json" mainConfig;

      nonoConfig = lib.recursiveUpdate baseConfig {
        permission = {
          "*" = "allow";
          bash = "allow";
          webfetch = "allow";
          websearch = "allow";
        };
      };
      nonoOpencodeJson = pkgs.writers.writeJSON "opencode-nono.json" nonoConfig;

      tuiJson = pkgs.writers.writeJSON "tui.json" {
        "$schema" = "https://opencode.ai/tui.json";
        theme = "tokyonight";
      };

      nonoProfile = ./nono-profile.json;
      nonoPkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.nono;
      opencodePkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

      nonoOpencode = pkgs.writeShellScriptBin "nono-opencode" ''
        # export OPENCODE_ENABLE_EXA=1
        export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
        export OPENCODE_CONFIG=${nonoOpencodeJson}
        exec ${nonoPkg}/bin/nono run --allow-cwd -p ${nonoProfile} -- ${opencodePkg}/bin/opencode "$@"
      '';

      opencode = pkgs.writeShellScriptBin "opencode" ''
        # export OPENCODE_ENABLE_EXA=1
        export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
        exec ${opencodePkg}/bin/opencode "$@"
      '';
    in
    lib.optionalAttrs (inputs ? llm-agents) {
      home.file =
        (mkOpencodeConfSymlinks [
          "commands"
          "agents"
          "AGENTS.md"
        ])
        // (mkSharedConfSymlinks ".config/opencode" [
          "docs"
          "skills"
        ])
        // {
          ".config/opencode/opencode.json".source = opencodeJson;
          ".config/opencode/opencode-nono.json".source = nonoOpencodeJson;
          ".config/opencode/tui.json".source = tuiJson;
        };

      home.packages = [
        nonoOpencode
        opencode
        nonoPkg
      ];
    };
}
