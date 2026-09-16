#!/usr/bin/env bash
set -euo pipefail

ISSUES_DIR="$(cd "$(dirname "$0")/issues" && pwd)"

for f in "$ISSUES_DIR"/*.md; do
  title=$(awk '/^---$/{if(++c==2)exit} c==1 && /^title:/{sub(/^title:[[:space:]]*/,""); print}' "$f")
  tmp=$(mktemp)
  awk '/^---$/{if(++c==2){body=1; next}} body{print}' "$f" > "$tmp"

  echo "Creating: $title"
  gh issue create --title "$title" --body-file "$tmp"

  rm "$tmp"
done
