#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused
# shellcheck shell=bash
set -euo pipefail

# Start in project root
cd "$(dirname "${BASH_SOURCE[0]}")/"

# Make sure the git repo is in fact nixkell before we nuke it
repo_url=$(git config --get remote.origin.url)
if [[ $(basename -s .git "$repo_url") != "nixkell" ]]; then
  echo "Not a nixkell repository, aborting..."
  exit 1
fi

# Nuke nixkell's .git and license
rm -rf .git
rm LICENSE

project_name=${PWD##*/}

# Blank slate readme
echo "# $project_name" > README.md

# Replace the dummy "replaceme" project names throughout with the actual one
nix_files=$(find . -type f -name "*.nix")
for i in $nix_files; do
  sed -i "s/replaceme/$project_name/g" "$i"
done
sed -i "s/replaceme/$project_name/g" ./package.yaml
sed -i "s/replaceme/$project_name/g" ./bin/Main.hs

# Fire up the nix shell
direnv allow .

# Finally delete this script
rm -f init
