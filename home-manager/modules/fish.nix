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
          rev = "e3b4d4eafc23516e35f162686f08a42edf844e40";
          sha256 = "1q4ya4ndm7d7kk8ppzvpsxmk0gkdpaqhp4n5j0mpxq7vv6yrhwvi";
        };
      }
      {
        name = "fish-docker";
        src = pkgs.fetchFromGitHub {
          owner = "halostatue";
          repo = "fish-docker";
          rev = "4eaabc8df954b1fafb3efcc10545b9c7c2dc4c55";
          sha256 = "1hgn1ly1q0a0cbq8lihrrg4m3kclr8xp1n4yx9150v701cqfa6my";
        };
      }
      {
        name = "cattpuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "cc8e4d8fffbdaab07b3979131030b234596f18da";
          sha256 = "1iqmchnz0gglwsxrqcm300754s84gsxrbwmfxh5mdlm16gcr9n5r";
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
      {
        # Syncs fish_completion_path from XDG_DATA_DIR, this makes completions
        # work with direnv (if the package is added to nativeBuildInputs)
        name = "fish-completion-sync";
        src = pkgs.fetchFromGitHub {
          owner = "pfgray";
          repo = "fish-completion-sync";
          rev = "f75ed04e98b3b39af1d3ce6256ca5232305565d8";
          hash = "sha256-wmtMUVi/NmbvJtrPbORPhAwXgnILvm4rjOtjl98GcWA=";
        };
      }
    ];

    shellAliases = {
      v = "nvim";
      l = "exa";
      fz = "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
      cdg = "cd (git rev-parse --show-toplevel)";
      svim = "nvim +'SLoad!'";
      h = "hctl";
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
      gri = "git rebase -i --committer-date-is-author-date --autostash";

      d = "docker";
      k = "kubectl";
      b = "bat";

      nr = "nix ~/dotfiles#nixosConfigurations.(hostname).pkgs.(fzf-nix)";
      ns = "nix shell ~/dotfiles#nixosConfigurations.(hostname).pkgs.(fzf-nix)";

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
