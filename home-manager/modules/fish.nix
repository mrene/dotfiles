{ config, pkgs, libs, ... }:
{
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
          rev = "76cac812064fa749ffc258a20398c6f6250860c5";
          sha256 = "13wm8lnb4r9agx13xp2b7hhmr3s3s6b7ici9m67w8npr3vjpcxpf";
        };
      }
      {
        name = "fish-docker";
        src = pkgs.fetchFromGitHub {
          owner = "halostatue";
          repo = "fish-docker";
          rev = "e925cd39231398b3842db1106af7acb4ec68dc79";
          sha256 = "0vr9450lx31kcv8nvn24fwrrk4ppym8i9ak4jmr01jp5himr4mdw";
        };
      }
      {
        name = "cattpuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "b90966686068b5ebc9f80e5b90fdf8c02ee7a0ba";
          sha256 = "1v38qn98cnha3vhvnax0ifwfz4l3awb5v3mdykxlz5d4591mh2f1";
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

      nr = "nix run nixpkgs#";

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
      gcloud = { disabled = true; };
      nix_shell = { disabled = true; };
      package = { disabled = true; };
    };
  };
}
