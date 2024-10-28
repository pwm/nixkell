{ system ? builtins.currentSystem, compiler ? null, }:
let pkgs = import ./. { inherit system compiler; };
in pkgs.nixkell
