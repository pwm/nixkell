{
  pkgs,
  compiler,
}: let
  lib = pkgs.lib;

  util = import ./util.nix {
    inherit pkgs;
    inherit (pkgs) lib gitignoreFilter;
  };

  conf = lib.importTOML ../nixkell.toml;

  ghcVersion =
    if compiler != null
    then compiler
    else conf.ghc.version;

  ghcVer = "ghc" + util.removeChar "." ghcVersion;

  hlsDisablePlugins =
    pkgs.lib.foldr
    (plugin: hls: pkgs.haskell.lib.disableCabalFlag (hls.override {${"hls-" + plugin + "-plugin"} = null;}) plugin);

  # Create your own setup using the choosen GHC version (in the config) as a starting point
  ourHaskell = pkgs.haskell.packages.${ghcVer}.override {
    overrides = hfinal: hprev: let
      # https://github.com/pwm/nixkell#direct-hackagegithub-dependencies
      depsFromDir = pkgs.haskell.lib.packagesFromDirectory {
        directory = ./packages;
      };

      manual = hfinal: hprev: {
        # Don't build plugins you don't use
        haskell-language-server =
          hlsDisablePlugins hprev.haskell-language-server conf.hls.disable_plugins;

        # https://github.com/NixOS/nixpkgs/issues/140774
        niv = pkgs.haskell.lib.overrideCabal hprev.niv (_: {
          enableSeparateBinOutput = false;
        });

        nixkell = let
          filteredSrc = util.filterSrc ../. {
            ignoreFiles = conf.ignore.files;
            ignorePaths = conf.ignore.paths;
          };
        in
          hprev.callCabal2nix "nixkell" filteredSrc {};
      };

      profilingOverrides = hfinal: hprev: {
        compiler = pkgs.haskell.compiler.${ghcVer}.override {
          enableProfiling = true;
          enableLibraryProfiling = true;
        };
        mkDerivation = args:
          hprev.mkDerivation (args // {enableLibraryProfiling = true;});
      };
    in
      lib.composeExtensions depsFromDir manual hfinal hprev
      // (
        if conf.ghc.profiling
        then profilingOverrides hfinal hprev
        else {}
      );
  };

  # Add our package with its dependencies to GHC
  ghc = ourHaskell.ghc.withPackages (
    _ps: pkgs.haskell.lib.getHaskellBuildInputs ourHaskell.nixkell
  );

  # Compile haskell tools with ourHaskell to ensure compatibility
  haskellTools = map (p: ourHaskell.${lib.removePrefix "haskellPackages." p}) conf.env.haskell_tools;

  tools = map util.getDrv conf.env.tools;

  scripts = import ./scripts.nix {inherit pkgs;};
in {
  bin = util.leanPkg ourHaskell.nixkell;

  shell = pkgs.buildEnv {
    name = "nixkell-env";
    paths = [ghc] ++ haskellTools ++ tools ++ scripts;
  };
}
