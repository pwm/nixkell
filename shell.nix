{ system ? builtins.currentSystem, compiler ? null, }:
let pkgs = import ./nix { inherit system compiler; };
in pkgs.mkShell {
  buildInputs = [ pkgs.nixkell.shell ];
  shellHook = ''
    export DEVSHELL_PATH="${pkgs.nixkell.shell}"
    export LD_LIBRARY_PATH="${pkgs.nixkell.shell}/lib$${LD_LIBRARY_PATH:+:$$LD_LIBRARY_PATH}"
    logo
  '';
}
