{ pkgs }:
let
  util = import ./util.nix { inherit (pkgs) lib gitignoreFilter; };

  scripts = import ./scripts.nix { inherit pkgs conf; };

  conf = pkgs.lib.importTOML ../nixkell.toml;

  # Add our package to haskellPackages
  haskellPackages = pkgs.haskell.packages.${("ghc" + util.removeDot conf.env.ghc)}.override {
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
      pkgs.lib.composeExtensions depsFromDir manual;
  };

  # Include our package dependencies with ghc
  ghc = haskellPackages.ghc.withPackages (_ps:
    pkgs.haskell.lib.getHaskellBuildInputs haskellPackages.replaceme
  );
in
{
  bin = haskellPackages.replaceme;

  shell = pkgs.buildEnv {
    name = "replaceme-env";
    paths = [ ghc ] ++ util.getFrom pkgs conf.env.packages ++ scripts;
  };
}
