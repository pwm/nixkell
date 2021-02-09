#!/usr/bin/env nix-shell
#!nix-shell -p gnused
#!nix-shell -i bash
# shellcheck shell=bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/"

# nuke nixkell's own .git dir
rm -rf .git

project_name=${PWD##*/}

nix_files=$(find . -type f -name "*.nix")
for i in $nix_files; do
  sed -i "s/replaceme/$project_name/g" "$i"
done
sed -i "s/replaceme/$project_name/g" ./package.yaml
sed -i "s/replaceme/$project_name/g" ./app/Main.hs
