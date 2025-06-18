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
  build-static = pkgs.writeShellScriptBin "build-static" ''
    set -euo pipefail
    nix-build nix/release.nix --arg static true
    # add Nix GC root for static dependencies and build tools
    nix-store --add-root .gcroots/static-deps \
      --realise `nix-instantiate --quiet --quiet --quiet nix/static-deps.nix` \
      > /dev/null
  '';
  run = pkgs.writeShellScriptBin "run" ''
    set -euo pipefail
    result/bin/nixkell "$@"
  '';
in
[ logo build build-static run ]
