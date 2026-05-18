_: {
  flake.aspects.dev.homeManager =
    { pkgs, ... }:
    {
      # Exposed as shell scripts (not fish functions) so they're callable from
      # non-fish contexts like scripts and Claude.
      home.packages = with pkgs; [
        (writeShellScriptBin "jj-main-branch" ''
          jj log --no-graph -r 'trunk()' -T 'coalesce(local_bookmarks)'
        '')
        (writeShellScriptBin "jj-current-branch" ''
          jj --ignore-working-copy log --no-graph -r "closest_bookmark(@)" -T 'local_bookmarks.map(|b| b.name()).join(",")'
        '')
        (writeShellScriptBin "jj-prev-branch" ''
          jj-stacked-branches | head -n 2 | tail -n 1
        '')
        (writeShellScriptBin "jj-diff-working" ''
          jj diff -r "$(jj-current-branch)..@" "$@"
        '')
        (writeShellScriptBin "jj-diff-branch" ''
          jj diff -r "$(jj-prev-branch)..@" "$@"
        '')
        (writeShellScriptBin "jj-stacked-branches" ''
          jj log --no-graph -r '(trunk()..@ | trunk()) & bookmarks()' -T 'coalesce(local_bookmarks) ++ "\n"' | sed 's/ *\*$//'
        '')
        (writeShellScriptBin "jj-stacked-stats" ''
          if [ -n "$1" ]; then
              from="$1"
          else
              from="trunk()"
          fi
          trunk=$(jj-main-branch)
          echo "Changes since $from:"
          jj log --reversed -r "$from..@" --no-graph -T 'change_id ++ "\n"' | while read -r change; do
              # Exclude trunk
              if [ "$change" = "$trunk" ]; then
                  continue
              fi

              jj log -r "$change"
              jj diff --stat -r "$change"
              echo -e "\n"
          done
        '')
      ];

      programs.fish = {
        functions = {
          jj-select = ''
            jj log --no-graph -T 'change_id.shortest() ++ "\t" ++ author.timestamp().ago() ++ " " ++ description.first_line() ++ " "  ++ bookmarks.join("  ") ++ "\n"' --color always | fzf --ansi --height 40% --layout reverse --border --preview 'jj diff --stat -r {1}' | cut -f1
          '';

          jj-b-select = ''
            jj log --no-graph -r 'bookmarks()' -T 'coalesce(local_bookmarks) ++ "\n"' --color always | sed 's/ *\\*$//' | fzf --ansi | cut -f1
          '';
        };

        shellAbbrs = {
          jjpr = {
            expansion = "gh pr create --head (jj-current-branch) --draft --body \"\" --title \"%\"";
            setCursor = true;
          };
          jjspr = {
            expansion = "gh pr create --base (jj-prev-branch) --head (jj-current-branch) --draft --body \"\" --title \"%\"";
            setCursor = true;
          };
          jjrt = "jj rebase-trunk";
          jjsi = "jj squash -t (jj-select) -i";
          jjsw = "jj squash-working";
          jjci = "jj commit -i";
          jjcm = {
            expansion = "jj commit -m \"%\"";
            setCursor = true;
          };
          jjcmi = {
            expansion = "jj commit -i -m \"%\"";
            setCursor = true;
          };
        };

        interactiveShellInit = ''
          # Bind Ctrl+Alt+J to select a jj revision
          bind -M insert ctrl-alt-j 'commandline -i (jj-select)'
        '';
      };

      programs.jujutsu = {
        enable = true;

        # See https://github.com/jj-vcs/jj/blob/main/docs/config.md
        # Some goodies from https://zerowidth.com/2025/jj-tips-and-tricks/#bookmarks-and-branches
        settings = {
          user = {
            name = "Mathieu Rene";
            email = "mathieu.rene@gmail.com";
          };
          ui = {
            paginate = "never";
            default-command = [
              "log"
              "--reversed"
            ];
          };

          git = {
            private-commits = "private()"; # prevent pushing private commits
          };

          revset-aliases = {
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
            "recent()" = "committer_date(after:\"1 months ago\")";
            "private()" = "description(glob:'private:*')";
            "claude()" = "description(glob:'private: claude:*')";
          };

          aliases = {
            # Move the most advanced bookmark between trunk and @- forward to the latest
            # non-private change. Uses `trunk()..` (not `::`) to exclude merge side-branches.
            # --from: find the head bookmark in trunk..@-, unioning trunk itself since `..` excludes it.
            # --to: head of trunk..@- after removing private changes and their descendants.
            "tug" = [
              "bookmark"
              "move"
              "--from"
              "heads(((trunk()..@-) | trunk()) & bookmarks())"
              "--to"
              "heads((trunk()..@-) ~ ((private() & (trunk()..@-))::))"
            ];

            # Rebase current branch onto trunk with support for multi-parents
            "rebase-trunk" = [
              "rebase"
              "-s"
              "roots(trunk()..@)" # root of any branches that leads us to trunk allowing support for multi-parents
              "-d"
              "trunk()" # rebase on trunk
            ];

            # Squash consecutive working changes (claude's, empty, undescribed) into @
            "squash-working" = [
              "squash"
              "--from"
              "(trunk()..@) & latest((trunk()..@) & ~(empty() | claude() | description(exact:'')))..(@- & (empty() | claude() | description(exact:'')))"
              "--to"
              "@"
            ];
          };
        };
      };
    };
}
