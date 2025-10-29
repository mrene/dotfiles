#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nodePackages.npm nix-update

set -euo pipefail

version=$(npm view @anthropic-ai/claude-code version)
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Generate updated lock file
cd "$SCRIPT_DIR"
npm i --package-lock-only @anthropic-ai/claude-code@"$version"
rm -f package.json

# Update version and hashes using wrapper that calls package.nix properly
# The attribute argument is required but ignored since our wrapper returns the derivation directly
nix-update --file "$SCRIPT_DIR/update-wrapper.nix" claude-code --version "$version"
