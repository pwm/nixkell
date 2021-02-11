{ pkgs, nixkellConfig }:
let
  greet = pkgs.writeShellScriptBin "greet" ''
    set -euo pipefail
    echo -e "\n\n    $(tput setaf 2)${nixkellConfig.greet}$(tput sgr0)\n\n"
  '';
  build = pkgs.writeShellScriptBin "build" ''
    set -euo pipefail
    hpack
    cabal2nix . > nix/packages/replaceme.nix
    nix-build nix/release.nix
  '';
  run = pkgs.writeShellScriptBin "run" ''
    set -euo pipefail
    result/bin/replaceme
  '';
in
[ greet build run ]
