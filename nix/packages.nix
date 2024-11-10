{ pkgs, compiler, }:
let
  lib = pkgs.lib;

  util = import ./util.nix {
    inherit pkgs;
    inherit (pkgs) lib gitignoreFilter;
  };

  conf = lib.importTOML ../nixkell.toml;

  ghcVersion = if compiler != null then compiler else conf.ghc.version;

  ghcVer = "ghc" + util.removeChar "." ghcVersion;

  hlib = pkgs.haskell.lib;

  confPkg = pkg:
    let
      usingOr = x: b: if conf.ghc ? ${x} then conf.ghc.${x} else b;
      confFns = [
        hlib.dontHyperlinkSource
        hlib.dontCoverage
        hlib.dontHaddock
        # https://downloads.haskell.org/ghc/latest/docs/users_guide/runtime_control.html
        (hlib.compose.appendConfigureFlags [
          "--ghc-option=+RTS"
          "--ghc-option=-A256m" # allocation area size
          "--ghc-option=-n2m" # allocation area chunksize
          "--ghc-option=-RTS"
        ])
      ] ++ pkgs.lib.optional (!(usingOr "optimise" true))
        hlib.disableOptimization
      ++ pkgs.lib.optional (usingOr "profiling" false)
        hlib.enableExecutableProfiling
      ++ pkgs.lib.optional (usingOr "benckmark" false) hlib.doBenchmark
      ++ pkgs.lib.optional pkgs.stdenv.isAarch64
        (hlib.compose.appendConfigureFlag
          "--ghc-option=-fwhole-archive-hs-libs");
    in
    lib.pipe pkg confFns;

  # pkgs/development/haskell-modules/configuration-hackage2nix/broken.yaml
  unbreak = drv:
    drv.overrideAttrs (prev: {
      meta = prev.meta // { broken = false; };
    });

  # By default they live in ./haskellPackages/patches
  patch = drv: patches:
    drv.overrideAttrs (prev: {
      patches = (prev.patches or [ ]) ++ patches;
    });

  hlsDisablePlugins =
    pkgs.lib.foldr
      (plugin: hls: hlib.disableCabalFlag
        (hls.override (_: { ${plugin} = null; }))
        plugin);

  # Create your own setup using the choosen GHC version (in the config) as a starting point
  ourHaskell =
    let
      # https://github.com/pwm/nixkell#direct-hackagegithub-dependencies
      depsFromDir = hlib.packagesFromDirectory { directory = ./packages; };

      manual = hfinal: hprev: {
        cabal-install = patch hprev.cabal-install
          [ ./patches/prevent_missing_index_error.patch ];

        haskell-language-server = hlsDisablePlugins hprev.haskell-language-server
          conf.hls.disable_plugins;

        nixkell =
          let
            cleanSource = util.filterSrc {
              path = ../.; # Root of the project
              files = conf.ignore.files;
              paths = conf.ignore.paths;
            };
          in
          confPkg (hprev.callCabal2nix "nixkell" cleanSource { });
      };
    in
    pkgs.haskell.packages.${ghcVer}.extend
      (lib.composeManyExtensions [ depsFromDir manual ]);

  # Add our package with its dependencies to GHC
  ghc = ourHaskell.ghc.withPackages (_:
    hlib.getHaskellBuildInputs (
      # Tell getHaskellBuildInputs to include benchmarkHaskellDepends
      # so that they are available in the shell for cabal to use them
      hlib.doBenchmark ourHaskell.nixkell));

  # Compile haskell tools with ourHaskell to ensure compatibility
  haskellTools =
    builtins.map (p: ourHaskell.${lib.removePrefix "haskellPackages." p})
      conf.env.haskell_tools;

  tools = builtins.map util.getDrv conf.env.tools;

  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  inherit conf ourHaskell ghc confPkg; # TODO: remove

  bin = ourHaskell.nixkell;

  shell = pkgs.buildEnv {
    name = "nixkell-env";
    paths = [ ghc ] ++ haskellTools ++ tools ++ scripts;
  };
}
