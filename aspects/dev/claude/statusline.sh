#!/usr/bin/env bash
# JSON payload docs: https://code.claude.com/docs/en/statusline.md
set -euo pipefail

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "?"')
cwd=$(echo "$input" | jq -r '.cwd // ""')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
if [[ -n "$project_dir" && "$cwd" == "$project_dir"* ]]; then
  dir="${cwd#"$project_dir"}"
  dir=".${dir:-/}" # prefix with ., default to / if empty
else
  dir=$(basename "$cwd")
fi

ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
usage=$(echo "$input" | jq -r '.context_window.current_usage // empty')

ORANGE='\033[38;5;208m'
RED='\033[0;31m'
NC='\033[0m'

if [[ -n "$usage" && "$ctx_size" -gt 0 ]]; then
  input_tokens=$(echo "$usage" | jq -r '.input_tokens // 0')
  cache_create=$(echo "$usage" | jq -r '.cache_creation_input_tokens // 0')
  cache_read=$(echo "$usage" | jq -r '.cache_read_input_tokens // 0')
  current=$((input_tokens + cache_create + cache_read))
  current_k=$((current / 1000))
  percent=$((current * 100 / ctx_size))

  if [[ "$current" -ge 130000 ]]; then
    ctx="${RED}${percent}% (${current_k}k)${NC}"
  elif [[ "$current" -ge 100000 ]]; then
    ctx="${ORANGE}${percent}% (${current_k}k)${NC}"
  else
    ctx="${percent}% (${current_k}k)"
  fi
else
  ctx="0%"
fi

branch=$(jj-current-branch 2>/dev/null || echo "?")

echo -e "📁 $dir 💭 $ctx 🔀 $branch 🤖 $model"
