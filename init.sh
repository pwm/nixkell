#!/usr/bin/env nix-shell
#!nix-shell -p gnused
#!nix-shell -i bash
# shellcheck shell=bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/"

project_name=${PWD##*/}

# nuke nixkell's own .git dir and license
rm -rf .git
rm LICENSE

nix_files=$(find . -type f -name "*.nix")
for i in $nix_files; do
  sed -i "s/replaceme/$project_name/g" "$i"
done
sed -i "s/replaceme/$project_name/g" ./package.yaml
sed -i "s/replaceme/$project_name/g" ./app/Main.hs

echo "# $project_name" > README.md
