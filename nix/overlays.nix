{ sources }:
[
  (final: prev: {
    inherit (import sources.gitignore { inherit (prev) lib; }) gitignoreFilter;
  })
  (final: prev: {
    util = (import ./util.nix { inherit (prev) lib gitignoreFilter; });
  })
  (final: prev: {
    replaceme = (import ./packages.nix { pkgs = prev; });
  })
]
