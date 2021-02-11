{ pkgs }: with pkgs;
let
  nixkellConfig = lib.importTOML ../nixkell.toml;

  haskellPackages = haskell.packages.${("ghc" + util.removeDot nixkellConfig.env.ghc)}.override {
    overrides = _hfinal: hprev: {
      replaceme =
        let
          filteredSrc = util.filterSrc ../. {
            ignoreFiles = nixkellConfig.ignore.files;
            ignorePaths = nixkellConfig.ignore.paths;
          };
        in
        hprev.callCabal2nix "replaceme" filteredSrc { };
    };
  };

  ghc = haskellPackages.ghc.withPackages (_ps:
    haskell.lib.getHaskellBuildInputs haskellPackages.replaceme
  );

  scripts = callPackage ./scripts.nix { inherit nixkellConfig; };
in
{
  bin = haskellPackages.replaceme;

  shell = buildEnv {
    name = "replaceme-env";
    paths = util.getFrom pkgs nixkellConfig.env.packages ++ scripts;
  };
}
