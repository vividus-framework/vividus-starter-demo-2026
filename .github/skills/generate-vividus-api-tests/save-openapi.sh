#!/usr/bin/env bash
# Fetches all InvenTree schema files from github.com/inventree/schema and prints
# the absolute path to the version folder.
# Usage: bash save-openapi.sh [API_VERSION]
# API_VERSION: optional version folder (e.g. 479). Omit to fetch the latest.
#
# Downloaded files:
#   <version>/api.yaml                 — OpenAPI specification
#   <version>/inventree_filters.yml    — Django template filters
#   <version>/inventree_settings.json  — Global & user settings with defaults
#   <version>/inventree_tags.yml       — Django template tags
set -euo pipefail

OWNER="inventree"
REPO="schema"
BRANCH="main"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_URL="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/export"

if [ -n "${1:-}" ]; then
  version="$1"
else
  response=$(curl -sf "https://api.github.com/repos/$OWNER/$REPO/contents/export?ref=$BRANCH") || {
    echo "Failed to list versions from GitHub API" >&2; exit 1
  }
  version=$(
    paste \
      <(echo "$response" | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/') \
      <(echo "$response" | grep '"type"' | sed 's/.*"type": *"\([^"]*\)".*/\1/') \
    | awk -F'\t' '$2 == "dir" {print $1}' \
    | sort -V | tail -n 1
  )
  [ -n "$version" ] || { echo "No version folders found in export/" >&2; exit 1; }
fi

OUTPUT_DIR="$SCRIPT_DIR/$version"
mkdir -p "$OUTPUT_DIR"

FILES=(
  "api.yaml"
  "inventree_filters.yml"
  "inventree_settings.json"
  "inventree_tags.yml"
)

for file in "${FILES[@]}"; do
  curl -sfL "$BASE_URL/$version/$file" -o "$OUTPUT_DIR/$file" || {
    echo "Failed to download '$file' for version '${version}'" >&2; exit 1
  }
  [ -s "$OUTPUT_DIR/$file" ] || { echo "Downloaded file is empty: $OUTPUT_DIR/$file" >&2; exit 1; }
done

echo "$OUTPUT_DIR"
