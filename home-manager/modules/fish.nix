{
  config,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;
    package = pkgs.fish;
    interactiveShellInit = ''

      # add completions generated by Home Manager to $fish_complete_path
      begin
        set -l joined (string join " " $fish_complete_path)
        set -l prev_joined (string replace --regex "[^\s]*generated_completions.*" "" $joined)
        set -l post_joined (string replace $prev_joined "" $joined)
        set -l prev (string split " " (string trim $prev_joined))
        set -l post (string split " " (string trim $post_joined))
        set fish_complete_path $prev "${config.xdg.dataHome}/fish/home-manager_generated_completions" $post
      end

      set PATH ~/.nix-profile/bin /nix/var/nix/profiles/default/bin ~/.cargo/bin ~/.deno/bin $GOPATH/bin ~/.npm-global-packages/bin $PATH

      # Setup terminal, and turn on colors
      set -x TERM xterm-256color

      # Enable color in grep
      # set -x GREP_OPTIONS '--color=auto'
      set -x GREP_COLOR '3;33'

      # language settings
      set -x LANG en_US.UTF-8
      set -x LC_CTYPE "en_US.UTF-8"
      set -x LC_MESSAGES "en_US.UTF-8"
      set -x LC_COLLATE C

      set EDITOR nvim

      # Enable direnv
      if command -v direnv &>/dev/null
          eval (direnv hook fish)
      end

      # Enable zoxice `z` (https://github.com/ajeetdsouza/zoxide)
      if command -v zoxide &>/dev/null
        zoxide init fish | source
      end

      any-nix-shell fish --info-right | source

      set -g theme_color_scheme "Catppuccin Mocha"

      bind \cg '${./fzf-ripgrep.sh}'
      bind \cn 'fzf-nix'
    '';
    functions = {
      o = ''
        if test (count $argv) -eq 0
          open .
        else
          open $argv
        end
      '';

      hm = ''
        pushd ~/dotfiles
        home-manager switch --flake .
        popd
      '';
    };
    plugins = [
      {
        name = "bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "05c0765c4ec4c8fee7e2d485587e033b9e4e4543";
          sha256 = "0kvqwlwgk03mqy6sjh4p5j6zdx4lwc3k94c88y8q7x87ds8z69cf";
        };
      }
      {
        name = "fish-docker";
        src = pkgs.fetchFromGitHub {
          owner = "halostatue";
          repo = "fish-docker";
          rev = "5b8266b0e3d78db1283a01d60724a9bc10325608";
          sha256 = "1zs7chvy28bz1l03z3dyv5i258pqw7wbbyb4qdvipdlbrn3adkzm";
        };
      }
      {
        name = "cattpuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "0ce27b518e8ead555dec34dd8be3df5bd75cff8e";
          sha256 = "1a6yj6zhccpg5jpcrxjzxyydh5ldwlvwf3vz6lwl60gk2xvz7kqd";
        };
      }
      {
        name = "fzf-fish";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "f9e2e48a54199fe7c6c846556a12003e75ab798e";
          hash = "sha256-CqRSkwNqI/vdxPKrShBykh+eHQq9QIiItD6jWdZ/DSM=";
        };
      }
    ];

    shellAliases = {
      v = "nvim";
      l = "exa";
      fz = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
      cdg = "cd (git rev-parse --show-toplevel)";
      svim = "nvim +'SLoad!'";
    };

    shellAbbrs = {
      s = "ssh";

      # git
      g = "git";
      gs = "git status";
      ga = "git add";
      gl = "git log --pretty=format:'%C(yellow)%h %Cred%ar %Cblue%an%Cgreen%d %Creset%s' --date=short";
      gt = "git tag --format='%(creatordate:short)%09%(refname:strip=2)' --sort=creatordate | tail -n10";
      gd = "git diff";
      gp = "git pull";
      gps = "git push";
      gcm = "git commit";
      gco = "git checkout";
      gcl = "git clone";

      d = "docker";
      k = "kubectl";
      b = "bat";

      nr = "nix run nixpkgs#(fzf-nix)";
      ns = "nix shell nixpkgs#(fzf-nix)";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      findport = "sudo lsof -iTCP -sTCP:LISTEN -n -P | grep";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      gcloud = {disabled = true;};
      nix_shell = {disabled = true;};
      package = {disabled = true;};
    };
  };
}
