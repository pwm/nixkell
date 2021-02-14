{ pkgs, conf }:
let
  greet = pkgs.writeShellScriptBin "greet" ''
    set -euo pipefail
    echo -e "\n$(tput setaf 2)"
    echo "${conf.greet}" | ${pkgs.figlet}/bin/figlet
    echo -e "$(tput sgr0)\n"
  '';
  build = pkgs.writeShellScriptBin "build" ''
    set -euo pipefail
    nix-build nix/release.nix
  '';
  run = pkgs.writeShellScriptBin "run" ''
    set -euo pipefail
    result/bin/replaceme
  '';
in
[ greet build run ]
