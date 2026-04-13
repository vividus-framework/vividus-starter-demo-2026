#!/usr/bin/env bash
# Fetches the latest InvenTree OpenAPI spec from github.com/inventree/schema
# and prints it to stdout so it can be consumed directly by the caller.
set -euo pipefail

OWNER="inventree"
REPO="schema"
BRANCH="main"

response=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/contents/export?ref=$BRANCH")

latest_dir=$(
  paste \
    <(echo "$response" | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/') \
    <(echo "$response" | grep '"type"' | sed 's/.*"type": *"\([^"]*\)".*/\1/') \
  | awk -F'\t' '$2 == "dir" {print $1}' \
  | sort -V \
  | tail -n 1
)

if [ -z "$latest_dir" ]; then
  echo "No folders found in export/" >&2
  exit 1
fi

curl -sL \
  "https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/export/$latest_dir/api.yaml"
