{ lib, pkgs, inputs, ... }:

let
  # Use the locally built claude-code package
  claudePkg = pkgs.callPackage ../claude-code/package.nix {};

  # Create wrapper for claude with proper config dir
  claude-wrapped = pkgs.writeShellScriptBin "claude" ''
    export CLAUDE_CONFIG_DIR="''${HOME}/.claude"
    exec ${claudePkg}/bin/claude "$@"
  '';

  # Build the container image with nix2container
  nix2container = inputs.nix2container.packages.${pkgs.system}.nix2container;

  # Create nix.conf for single-user mode
  nixConf = pkgs.writeTextFile {
    name = "nix.conf";
    text = ''
      experimental-features = nix-command flakes
      substituters = https://cache.nixos.org http://nas:8501/
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
      sandbox = false
    '';
  };

  # Container image
  image = nix2container.buildImage {
    name = "claude-sandbox";
    #tag = "latest";

    # Enable nix database initialization with user ownership
    initializeNixDatabase = true;
    nixUid = 1000;
    nixGid = 100;

    # Set up the basic system
    copyToRoot = pkgs.buildEnv {
      name = "claude-sandbox-root";
      paths = [
        # Core system utilities
        pkgs.coreutils
        pkgs.bash
        pkgs.fish
        pkgs.nix

        # Claude and wrapper
        claude-wrapped

        # Development tools that claude might need
        pkgs.git
        pkgs.curl
        pkgs.gnugrep
        pkgs.gnused
        pkgs.findutils
        pkgs.gawk

        # CA certificates for HTTPS
        pkgs.cacert
      ];
      pathsToLink = [ "/bin" "/etc" "/share" "/lib" ];
    };

    config = {
      Cmd = [ "${claude-wrapped}/bin/claude" ];
      Env = [
        "PATH=/bin"
        "NIX_CONF_DIR=/etc/nix"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      WorkingDir = "/workspace";
    };

    # Copy nix configuration
    perms = [
      {
        path = nixConf;
        regex = ".*";
        mode = "0644";
      }
    ];
  };

  # Create a wrapper script to launch the container
  launcher = pkgs.writeShellApplication {
    name = "claude-sandboxed";

    runtimeInputs = with pkgs; [
      docker
      coreutils
    ];

    text = ''
      INIT_DIR=$(pwd)
      USER_UID=$(id -u)
      USER_GID=$(id -g)

      # Parse --flake argument
      FLAKE_TARGET=""
      CLAUDE_ARGS=()
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --flake)
            FLAKE_TARGET="$2"
            shift 2
            ;;
          *)
            CLAUDE_ARGS+=("$1")
            shift
            ;;
        esac
      done

      # Use the image reference from nix2container (includes hash for version matching)
      IMAGE_REF="${image.imageName}:${image.imageTag}"

      # Only load the image if it doesn't already exist in docker
      if ! docker image inspect "$IMAGE_REF" >/dev/null 2>&1; then
        echo "Loading claude-sandbox image..."
        ${lib.getExe image.copyToDockerDaemon}
      fi

      # Prepare arguments
      if [ -n "''${ENTRYPOINT:-}" ]; then
        EXEC_CMD="$ENTRYPOINT"
        ARGS=("''${CLAUDE_ARGS[@]}")
      else
        # If --flake was provided, wrap with nix develop
        if [ -n "$FLAKE_TARGET" ]; then
          EXEC_CMD="nix"
          ARGS=(develop --no-pure-eval --accept-flake-config "$FLAKE_TARGET" --command "${lib.getExe claude-wrapped}" --dangerously-skip-permissions --add-dir "$HOME" "''${CLAUDE_ARGS[@]}")
        else
          EXEC_CMD="${lib.getExe claude-wrapped}"
          ARGS=(--dangerously-skip-permissions --add-dir "$HOME" "''${CLAUDE_ARGS[@]}")
        fi
      fi

      # Create temporary passwd and group files with current user
      TMPDIR=$(mktemp -d)
      trap 'rm -rf "$TMPDIR"' EXIT

      echo "root:x:0:0:root:/root:/bin/bash" > "$TMPDIR/passwd"
      echo "$USER:x:$USER_UID:$USER_GID:$USER:$HOME:/bin/bash" >> "$TMPDIR/passwd"

      echo "root:x:0:" > "$TMPDIR/group"
      echo "$USER:x:$USER_GID:" >> "$TMPDIR/group"

      # Run the container
      docker run --rm -it \
        --hostname "$(hostname)" \
        --user "$USER_UID:$USER_GID" \
        --workdir "$INIT_DIR" \
        --tmpfs "$HOME:rw,exec,uid=$USER_UID,gid=$USER_GID" \
        --tmpfs "/tmp:rw,exec,uid=$USER_UID,gid=$USER_GID" \
        --volume "$INIT_DIR:$INIT_DIR" \
        --volume "$HOME/.claude:$HOME/.claude:rw" \
        --volume "$HOME/.config/nix:$HOME/.config/nix:ro" \
        --volume "$TMPDIR/passwd:/etc/passwd:ro" \
        --volume "$TMPDIR/group:/etc/group:ro" \
        --env "HOME=$HOME" \
        --env "USER=$USER" \
        --env "LOGNAME=$LOGNAME" \
        --env "CLAUDE_CONFIG_DIR" \
        --env "NIX_REMOTE=" \
        "$IMAGE_REF" \
        "$EXEC_CMD" "''${ARGS[@]}"
    '';
  };
in

launcher
