{ compiler }:
let
  getGHCWithVersion = lib:
    let
      conf = lib.importTOML ../nixkell.toml;
      ghcVersion = if compiler != null then compiler else conf.ghc.version;
      removeChar = c: s: lib.replaceStrings [ c ] [ "" ] s;
    in
    "ghc" + removeChar "." ghcVersion;
in
[
  # override GHC to do static builds
  (final: prev:
    let
      compiler = getGHCWithVersion prev.lib;
      prevHPackages = prev.haskell.packages.${compiler};
    in
    prev.lib.attrsets.recursiveUpdate prev {
      haskell.packages.${compiler} = prevHPackages.override {
        ghc = prevHPackages.ghc.override {
          enableRelocatedStaticLibs = true;
          enableShared = false;
          enableDwarf = false;
          enableProfiledLibs = false;
          enableDocs = false;
        };
        buildHaskellPackages = prevHPackages.buildHaskellPackages.override (old: {
          ghc = final.haskell.packages.${compiler}.ghc;
        });
      };
    }
  )

  # override cabal2nix to use the overridden GHC
  (final: prev:
    let compiler = getGHCWithVersion prev.lib;
    in {
      haskellPackages = prev.haskell.packages.${compiler};
      ghc = prev.haskell.packages.${compiler}.ghc;
    }
  )

  # override haskell package derivation to disable tests, docs and profiling
  (final: prev: {
    haskell = prev.haskell // {
      packageOverrides = prev.lib.composeExtensions prev.haskell.packageOverrides (
        hfinal: hprev: {
          mkDerivation = args: hprev.mkDerivation (
            args // {
              doCheck = false;
              doHaddock = false;
              enableLibraryProfiling = false;
              enableExecutableProfiling = false;
            }
          );
        }
      );
    };
  })
]
