{ pkgs }:
let
  logo = pkgs.writeShellScriptBin "logo" ''
    set -euo pipefail
    echo -e "\n$(tput setaf 2)"
    echo Nixkell | ${pkgs.figlet}/bin/figlet
    echo -e "$(tput sgr0)\n"
  '';
  build = pkgs.writeShellScriptBin "build" ''
    set -euo pipefail
    nix-build nix/release.nix
  '';
  run = pkgs.writeShellScriptBin "run" ''
    set -euo pipefail
    result/bin/nixkell "$@"
  '';
in [ logo build run ]
