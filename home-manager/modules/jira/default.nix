{pkgs, ...}: {
  # TODO: Add api token via sops-nix
  xdg.configFile.".jira/.config.yaml".source = ./config.yml;

  home.packages = with pkgs; [
    # jira-cli-go
  ];

  programs.fish.functions.j = ''
    set SEARCH_QUERY 'jira sprint list --current -a(jira me) --plain --columns "key,summary,status" --order-by rank --reverse'
    env FZF_DEFAULT_COMMAND=$SEARCH_QUERY fzf \
      --height 40% \
      --reverse \
      --header-lines=1 \
      --preview 'jira issue view {1}' \
      --preview-window 'right,:+6' \
      --bind 'ctrl-r:reload:'$SEARCH_QUERY \
      --bind 'e:execute(jira issue edit {1})' \
      --bind 'm:execute(jira issue move {1})' \
      --header '<m> Move to column | <C-r> Reload'
  '';
}
