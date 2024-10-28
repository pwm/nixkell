{ system ? builtins.currentSystem, compiler ? null, }:
let pkgs = import ./nix { inherit system compiler; };
in pkgs.mkShell {
  buildInputs = [ pkgs.nixkell.shell ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.nixkell.shell}/lib:$LD_LIBRARY_PATH
    logo
  '';
}
