{ system ? builtins.currentSystem }:
let
  pkgs = import ./nix { inherit system; };
in
with pkgs; mkShell {
  buildInputs = [
    replaceme.shell
  ];
  shellHook = ''
    export LD_LIBRARY_PATH=${replaceme.shell}/lib:$LD_LIBRARY_PATH
    greet
  '';
}
