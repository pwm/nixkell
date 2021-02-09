{ sources }:
[
  (final: _prev: {
    inherit (import sources.gitignore { inherit (final) lib; }) gitignoreFilter;
  })
  (final: _prev: {
    util = (import ./util.nix { inherit (final) lib gitignoreFilter; });
  })
  (final: _prev: {
    replaceme = (import ./packages.nix { pkgs = final; });
  })
]
