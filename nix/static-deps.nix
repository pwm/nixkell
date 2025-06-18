{ compiler ? null }:
let
  pkgs = import ./. {
    inherit compiler;
    static = true;
    system = "x86_64-linux";
  };
in
pkgs.nixkell.staticDeps
