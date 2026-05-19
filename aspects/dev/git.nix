{ config, ... }:
{
  flake.aspects.dev.homeManager =
    { pkgs, ... }:
    let
      inherit (config.npins) delta;
    in
    {
      programs.git = {
        enable = true;
        lfs.enable = true;

        settings = {
          user = {
            name = "Mathieu Rene";
            email = "mathieu.rene@gmail.com";
          };

          github.user = "mrene";
          push.autoSetupRemote = true;

          core = {
            editor = "nvim";
            fileMode = false;
            ignorecase = false;
          };

          include = {
            path = "${./delta}/themes.gitconfig";
          };
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          navigate = true; # N to switch files
          syntax-theme = "Nord";
          side-by-side = false;
          features = "chameleon-mod";
        };
      };

      # fzf-driven git helpers. See https://github.com/junegunn/fzf-git.sh/blob/main/fzf-git.sh
      programs.fish.functions = {
        gb = ''
          set COMMAND 'git for-each-ref --sort=-committerdate refs/heads/ --format="%(color: red)%(committerdate:short)%(color: 244)|%(color: cyan)%(refname:short)%(color: 244)|%(color: green)%(subject)" --color=always | column -ts"|"'
          FZF_DEFAULT_COMMAND=$COMMAND fzf \
            --ansi \
            --header "enter to checkout, ctrl-d to delete" \
            --bind "ctrl-d:execute(echo {+} | awk '{print \$2}' | xargs git branch -D)+reload:$COMMAND" \
            | awk '{print $2}' | xargs git checkout
        '';

        gcpm = ''
          MSG=(git log --first-parent --pretty=format:%s | head -n 100 | uniq | head -n 10 | fzf) git commit -m "$MSG"
        '';

        gh-pr-select = ''
          set COMMAND 'gh pr list --json number,title,author,headRefName,updatedAt \
          --template "{{tablerow \"Ref\" \"PR\" \"Title\" \"Author\" \"Date\"}}{{range .}}{{tablerow (.headRefName | color \"blue\") (printf \"#%v\" .number | color \"yellow\") (.title | color \"green\") (.author.name | color \"cyan\") (timeago .updatedAt)}}{{end}}"'
          GH_FORCE_TTY=100% FZF_DEFAULT_COMMAND=$COMMAND fzf \
                    --ansi \
                    --header-lines=1 \
                    --no-multi \
                    --prompt 'Search Open PRs > ' \
                    | awk '{print $1}'
        '';

        git-tag-select = ''
          set COMMAND "git tag -l --sort=-version:refname --color=always --format='%(color:red)%(refname:short) %(color: cyan) - %(color: green)%(creatordate:short)'"
          FZF_DEFAULT_COMMAND=$COMMAND fzf \
                  --ansi \
                  --prompt 'Search tags > ' \
                  | awk '{print $1}'
        '';
      };
    };
}
