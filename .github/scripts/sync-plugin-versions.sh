#!/usr/bin/env bash
#
# Sync .claude-plugin/marketplace.json plugin versions to the latest GitHub
# release of each plugin, and patch-bump metadata.version if anything changed.
#
# Writes step outputs to $GITHUB_OUTPUT (a throwaway file when run locally):
#   changed   - "true" | "false"
#   changes   - markdown bullet list of plugin bumps (multiline; only when changed)
#   meta_old  - previous metadata.version                (only when changed)
#   meta_new  - bumped metadata.version                  (only when changed)
#
# Requires: gh (authenticated via GH_TOKEN) and jq.
# Env overrides: MARKETPLACE_FILE (default .claude-plugin/marketplace.json).

set -euo pipefail

marketplace="${MARKETPLACE_FILE:-.claude-plugin/marketplace.json}"
# GITHUB_OUTPUT is unset when running locally; discard outputs in that case.
output="${GITHUB_OUTPUT:-/dev/null}"

changes=""

count=$(jq '.plugins | length' "$marketplace")
for ((i = 0; i < count; i++)); do
  name=$(jq -r ".plugins[$i].name" "$marketplace")
  repo=$(jq -r ".plugins[$i].source.repo" "$marketplace")
  current=$(jq -r ".plugins[$i].version" "$marketplace")

  # Latest published release, with any leading "v" stripped.
  latest=$(gh api "repos/$repo/releases/latest" --jq '.tag_name' 2>/dev/null | sed 's/^v//') || latest=""
  if [ -z "$latest" ]; then
    echo "::warning::No latest release found for $repo, skipping $name"
    continue
  fi

  if [ "$latest" = "$current" ]; then
    echo "$name is up to date ($current)"
    continue
  fi

  echo "Bumping $name: $current -> $latest"
  jq --arg n "$name" --arg v "$latest" \
    '(.plugins[] | select(.name == $n) | .version) = $v' \
    "$marketplace" > "$marketplace.tmp"
  mv "$marketplace.tmp" "$marketplace"
  changes="${changes}- Bump \`$name\` from $current to $latest"$'\n'
done

if [ -z "$changes" ]; then
  echo "No plugin updates available."
  echo "changed=false" >> "$output"
  exit 0
fi

# Patch-bump the marketplace metadata version.
old=$(jq -r '.metadata.version' "$marketplace")
IFS='.' read -r major minor patch <<< "$old"
new="$major.$minor.$((patch + 1))"
jq --arg v "$new" '.metadata.version = $v' \
  "$marketplace" > "$marketplace.tmp"
mv "$marketplace.tmp" "$marketplace"
echo "Bumping marketplace metadata: $old -> $new"

# Fail loudly if we somehow produced invalid JSON.
jq empty "$marketplace"

{
  echo "changed=true"
  echo "meta_old=$old"
  echo "meta_new=$new"
  echo "changes<<CHANGES_EOF"
  echo "${changes%$'\n'}"
  echo "CHANGES_EOF"
} >> "$output"
