#!/usr/bin/env nix-shell
#!nix-shell -p gnused
#!nix-shell -i bash
# shellcheck shell=bash
set -euo pipefail

# Start in project root
cd "$(dirname "${BASH_SOURCE[0]}")/"

project_name=${PWD##*/}

# Nuke nixkell's own .git and license
rm -rf .git
rm LICENSE

# Fresh readme
echo "# $project_name" > README.md

# Replace dummy "replaceme" project name with the real one
nix_files=$(find . -type f -name "*.nix")
for i in $nix_files; do
  sed -i "s/replaceme/$project_name/g" "$i"
done
sed -i "s/replaceme/$project_name/g" ./package.yaml
sed -i "s/replaceme/$project_name/g" ./bin/Main.hs

# Fire up the nix shell
direnv allow .
