{ system ? builtins.currentSystem, compiler ? null, static ? false }:
let
  pkgs = import ./. {
    inherit compiler static;
    system = if static then "x86_64-linux" else system;
  };
  nixkell = pkgs.nixkell;
in
if static then nixkell.bin else nixkell
