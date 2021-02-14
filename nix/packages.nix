{ pkgs }:
let
  util = (import ./util.nix { inherit (pkgs) lib gitignoreFilter; });

  conf = pkgs.lib.importTOML ../nixkell.toml;

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

  ghc = haskellPackages.ghc.withPackages (_ps:
    pkgs.haskell.lib.getHaskellBuildInputs haskellPackages.replaceme
  );

  scripts = pkgs.callPackage ./scripts.nix { inherit conf; };
in
{
  bin = haskellPackages.replaceme;

  shell = pkgs.buildEnv {
    name = "replaceme-env";
    paths = [ ghc ] ++ util.getFrom pkgs conf.env.packages ++ scripts;
  };
}
