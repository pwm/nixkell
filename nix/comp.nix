{ pkgs }:
let
  comp = pkgs.writeShellScriptBin "comp" ''
    set -euo pipefail
    hpack
    cabal2nix . > nix/packages/replaceme.nix
    nix-build nix/release.nix
  '';
in
comp
