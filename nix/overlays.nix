{ sources, compiler }:
[
  (final: prev: {
    inherit (import sources.gitignore { inherit (prev) lib; }) gitignoreFilter;
  })
  (final: prev: {
    replaceme = import ./packages.nix { pkgs = prev; inherit compiler; };
  })
]
