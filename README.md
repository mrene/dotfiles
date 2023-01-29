

Heavily inspired from: https://github.com/schickling/dotfiles/
Also see: https://github.com/malob/nixpkgs


## Installing on a new environment
- [Install nix](https://nixos.org/download.html)
- Enable flakes
    - `mkdir -p ~/.config/nix/ && echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf`
- For darwin:
    - `nix build .#darwinConfigurations.Mathieus-MacBook-Pro.system` then `./result/sw/bin/darwin-rebuild switch --flake . --show-trace`
- For home-manager (install or update configs):
    - `nix build .#homeConfigurations.mrene@(hostname).activationPackage && ./result/activate`
    - `run diff` can diff package differences before applying them
        - `nvd diff /nix/var/nix/profiles/per-user/$USER/home-manager/ ./result`

## Scratchpad from whenever this was written
- darwin-rebuild didn't properly activate the nix profile automatically, but this did: `nix run nixpkgs#home-manager -- switch --flake .`

## Manually activating home-manager
This works because the flake itself depends on home manager



## NixOS
Test in a vm:
    `nixos-generate -f vm --flake .# --run`