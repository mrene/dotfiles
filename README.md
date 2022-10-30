Heavily inspired from: https://github.com/schickling/dotfiles/

Also see: https://github.com/malob/nixpkgs

nix build .#darwinConfigurations.Mathieus-MacBook-Pro.system
./result/sw/bin/darwin-rebuild switch --flake . --show-trace

- darwin-rebuild didn't properly activate the nix profile automatically, but this did:
nix run nixpkgs#home-manager -- switch --flake .
