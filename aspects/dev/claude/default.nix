{ inputs, lib, ... }:
{
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.aspects.dev-claude.homeManager =
    { pkgs, config, ... }:
    let
      dotfilesPath = "${config.home.homeDirectory}/nixworld/dotfiles";

      # Symlink config files from the dotfiles repo so claude can edit them in place
      mkClaudeConfSymlinks =
        paths:
        lib.listToAttrs (
          map (path: {
            name = ".claude/${path}";
            value = {
              source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/aspects/dev/claude/${path}";
            };
          }) paths
        );

      claude-code = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

      claude-wrapped = pkgs.writeShellScriptBin "claude" ''
        # # Warn if not in a git repo
        # if [ ! -d ".git" ]; then
        #   echo -e "\e[31mWARNING: No .git, are you at the root of a project?\e[0m" >&2
        #   sleep 5
        # fi

        export CLAUDE_CONFIG_DIR="${config.home.homeDirectory}/.claude"
        export CLAUDE_ROOT="''${CLAUDE_PROJECT_DIR:-$(pwd)}"

        ${claude-code}/bin/claude "$@"
      '';

      claude-proj-docs = pkgs.writeShellScriptBin "claude-proj-docs" ''
        if [ -d "''${CLAUDE_ROOT:-$(pwd)}/proj" ]; then
          echo "proj/ files:"
          ls "''${CLAUDE_ROOT:-$(pwd)}/proj/"
        else
          echo "No project files"
        fi
      '';

      sandboxed-version = "13";
      passthrough-env-vars = [
        "HOME"
        "PATH"
        "TERM"
        "COLORTERM"
        "SHELL"
        "GOROOT"
        "GOBIN"
        "MISE_SHELL"
        "NIX_PROFILES"
        "NIX_PATH"
        "LANG"
        "USER"
        "LOGNAME"
        "RUST_LOG"
        "RUST_BACKTRACE"
        "PYTHONPATH"
        "PYTHON_LD_LIBRARY_PATH"
        "LD_LIBRARY_PATH"
        "PKG_CONFIG_PATH"
        "CPATH"
        "LIBRARY_PATH"
      ];
      mkDockerProfileExports =
        vars:
        "RUN "
        + lib.concatMapStringsSep " && \\\n    " (
          var: "echo 'export ${var}=\"\$${var}\"' >> /etc/profile"
        ) vars;
      mkDockerEnvArgs = vars: lib.concatMapStringsSep " \\\n        " (var: "--env \"${var}\"") vars;

      claude-sandboxed = pkgs.writeShellApplication {
        name = "claude-sandboxed";
        bashOptions = [ "errexit" ];
        checkPhase = "";
        runtimeInputs = with pkgs; [
          docker
          coreutils
        ];
        text = ''
          INIT_DIR=$(pwd)

          USER_UID=$(id -u)
          USER_GID=$(id -g)

          CURRENT_PATH="$PATH"
          ENV_VARS_HASH="${builtins.hashString "sha256" (builtins.concatStringsSep "," passthrough-env-vars)}"
          PATH_HASH=$(echo "$CURRENT_PATH ${sandboxed-version} ${claude-wrapped}/bin/claude $ENV_VARS_HASH" | sha256sum | cut -c1-12)
          IMAGE_NAME="claude-alpine-$PATH_HASH"
          if ! docker images | grep -q "$IMAGE_NAME"; then
            echo "Building $IMAGE_NAME with current PATH..."
            cat << EOF > /tmp/Dockerfile.claude-"$PATH_HASH"
          FROM alpine:latest
          RUN apk add --no-cache bash fish

          ${mkDockerProfileExports passthrough-env-vars}

          EOF
            docker build -f /tmp/Dockerfile.claude-"$PATH_HASH" -t "$IMAGE_NAME" /tmp
            rm /tmp/Dockerfile.claude-"$PATH_HASH"
          fi

          if [ -n "''${ENTRYPOINT:-}" ]; then
            EXEC_CMD="$ENTRYPOINT"
            ARGS=("$@")
          else
            EXEC_CMD="${claude-wrapped}/bin/claude"
            ARGS=(--dangerously-skip-permissions --add-dir "${config.home.homeDirectory}" "$@")
          fi

          docker run --rm -it \
            --hostname "$(hostname)" \
            --user "$USER_UID:$USER_GID" \
            --workdir "$INIT_DIR" \
            --volume "$INIT_DIR:$INIT_DIR" \
            --volume "${config.home.homeDirectory}:${config.home.homeDirectory}:ro" \
            --volume "${config.home.homeDirectory}/.claude:${config.home.homeDirectory}/.claude:rw" \
            --volume "${config.home.homeDirectory}/.cache:${config.home.homeDirectory}/.cache:rw" \
            --volume "${config.home.homeDirectory}/.cargo:${config.home.homeDirectory}/.cargo:rw" \
            --volume "${config.home.homeDirectory}/.npm:${config.home.homeDirectory}/.npm:rw" \
            --volume "${config.home.homeDirectory}/go:${config.home.homeDirectory}/go:rw" \
            --volume "${dotfilesPath}/aspects/dev/claude:${dotfilesPath}/aspects/dev/claude:rw" \
            --volume "/etc/nix:/etc/nix:ro" \
            --volume "/etc/static/nix:/etc/static/nix:ro" \
            --volume "/nix:/nix:ro" \
            --volume "/run:/run:ro" \
            --env "CLAUDE_CONFIG_DIR" \
            --network host \
            --pid host \
            ${mkDockerEnvArgs passthrough-env-vars} \
            "$IMAGE_NAME" \
            "$EXEC_CMD" ''${ARGS[@]}
        '';
      };
    in
    lib.optionalAttrs (inputs ? llm-agents) {
      home.file = mkClaudeConfSymlinks [
        "settings.json"
        "commands"
        "docs"
        "agents"
        "skills"
        "CLAUDE.md"
        "statusline.sh"
      ];

      home.packages = [
        claude-sandboxed
        claude-wrapped
        claude-proj-docs
        pkgs.socat
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.workmux
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        pkgs.bubblewrap
      ];
    };
}
