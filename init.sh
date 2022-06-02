#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnused
# shellcheck shell=bash
set -euo pipefail

# Start in project root
cd "$(dirname "${BASH_SOURCE[0]}")/"

# Make sure the git repo is in fact Nixkell's before nuking stuff
repo_url=$(git config --get remote.origin.url)
if [[ $(basename -s .git "$repo_url") != "nixkell" ]]; then
  echo "Not a nixkell repository, aborting..."
  exit 1
fi

# Nuke nixkell's .git, assets and init new repo
rm -rf .git
rm -rf assets
git init .

project_name=${PWD##*/}

# Blank slate readme
echo "# $project_name" >README.md

# Replace all dummy "replaceme" with the project name
for i in $(find . -type f -name "*.nix"); do
  sed -i "s/replaceme/$project_name/g" "$i"
done
sed -i "s/replaceme/$project_name/g" ./package.yaml
sed -i "s/replaceme/$project_name/g" ./bin/Main.hs

# comment out the Nixkell specific cachix entry from the CI config
sed -i -e "s/pwm/$project_name/" -e '/cachix-action/,+3 s/.*/# &/' '.github/workflows/nix.yml'

# Create an .envrc and fire up the nix shell with it
cat >.envrc <<EOF
#!/usr/bin/env bash
use nix
watch_file nixkell.toml
watch_file package.yaml
watch_file nix/*
EOF
direnv allow .

# Finally delete this script
rm -f init.sh
