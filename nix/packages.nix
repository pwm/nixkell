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
    else conf.ghc;

  hlsDisablePlugins =
    pkgs.lib.foldr
    (plugin: hls: pkgs.haskell.lib.disableCabalFlag (hls.override {${"hls-" + plugin + "-plugin"} = null;}) plugin);

  # Create your own setup using the choosen GHC version (in the config) as a starting point
  ourHaskell = pkgs.haskell.packages.${"ghc" + util.removeChar "." ghcVersion}.override {
    overrides = let
      # https://github.com/pwm/nixkell#direct-hackagegithub-dependencies
      depsFromDir = pkgs.haskell.lib.packagesFromDirectory {
        directory = ./packages;
      };

      manual = _hfinal: hprev: {
        # Don't build plugins you don't use
        haskell-language-server =
          hlsDisablePlugins hprev.haskell-language-server conf.hls.disable_plugins;

        nixkell = let
          filteredSrc = util.filterSrc ../. {
            ignoreFiles = conf.ignore.files;
            ignorePaths = conf.ignore.paths;
          };
        in
          hprev.callCabal2nix "nixkell" filteredSrc {};
      };
    in
      lib.composeExtensions depsFromDir manual;
  };

  # Add our package with its dependencies to GHC
  ghc = ourHaskell.ghc.withPackages (
    _ps: pkgs.haskell.lib.getHaskellBuildInputs ourHaskell.nixkell
  );

  # Compile haskell tools with ourHaskell to ensure compatibility
  haskell_tools = map (p: ourHaskell.${lib.removePrefix "haskellPackages." p}) conf.env.haskell_tools;

  tools = map util.getDrv conf.env.tools;

  scripts = import ./scripts.nix {inherit pkgs;};
in {
  bin = util.leanPkg ourHaskell.nixkell;

  shell = pkgs.buildEnv {
    name = "nixkell-env";
    paths = [ghc] ++ haskell_tools ++ tools ++ scripts;
  };
}
