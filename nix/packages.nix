{ pkgs }:
let
  lib = pkgs.lib;

  util = import ./util.nix {
    inherit pkgs;
    inherit (pkgs) lib gitignoreFilter;
  };

  conf = lib.importTOML ../nixkell.toml;

  # Create our haskell from the choosen version of the default one
  ourHaskell = pkgs.haskell.packages.${("ghc" + util.removeDot conf.ghc)}.override {
    overrides =
      let
        depsFromDir = pkgs.haskell.lib.packagesFromDirectory {
          directory = ./packages;
        };
        manual = _hfinal: hprev: {
          replaceme =
            let
              filteredSrc = util.filterSrc ../. {
                ignoreFiles = conf.ignore.files;
                ignorePaths = conf.ignore.paths;
              };
            in
            hprev.callCabal2nix "replaceme" filteredSrc { };
        };
      in
      lib.composeExtensions depsFromDir manual;
  };

  # Include our package dependencies with ghc
  ghc = ourHaskell.ghc.withPackages (_ps:
    pkgs.haskell.lib.getHaskellBuildInputs ourHaskell.replaceme
  );

  tools = util.buildWith ourHaskell [ "haskell-language-server" ] conf.env.tools;

  scripts = import ./scripts.nix { inherit pkgs conf; };
in
{
  bin = util.leanPkg ourHaskell.replaceme;

  shell = pkgs.buildEnv {
    name = "replaceme-env";
    paths = [ ghc ] ++ tools ++ scripts;
  };
}
