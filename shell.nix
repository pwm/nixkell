{ system ? builtins.currentSystem }:
let
  pkgs = import ./nix { inherit system; };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.replaceme.shell
  ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.replaceme.shell}/lib:$LD_LIBRARY_PATH
    logo
  '';
}
