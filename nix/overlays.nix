{ sources, compiler, static }: [
  (final: prev: {
    inherit (import sources.gitignore { inherit (prev) lib; }) gitignoreFilter;
  })
]
++ (if static then import ./overlays-static.nix { inherit compiler; } else [ ])
++ [
  (final: prev: {
    nixkell = import ./packages.nix {
      pkgs = if static then final.pkgsMusl else final;
      inherit compiler static;
    };
  })
]
