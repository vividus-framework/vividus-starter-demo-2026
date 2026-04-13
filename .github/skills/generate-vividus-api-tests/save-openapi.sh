#!/usr/bin/env bash
# Fetches the latest InvenTree OpenAPI spec from github.com/inventree/schema,
# saves it to .github/skills/generate-vividus-api-tests/openapi.yaml inside the
# repository, and prints the absolute path to stdout for the caller to use.
set -euo pipefail

OWNER="inventree"
REPO="schema"
BRANCH="main"

# Resolve the repository root (directory containing this script's parent chain)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/openapi.yaml"

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
  "https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/export/$latest_dir/api.yaml" \
  -o "$OUTPUT_FILE"

if [ ! -s "$OUTPUT_FILE" ]; then
  echo "Downloaded file is empty: $OUTPUT_FILE" >&2
  exit 1
fi

echo "$OUTPUT_FILE"
