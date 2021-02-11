{ pkgs }: with pkgs;
let
  nixkellConfig = lib.importTOML ../nixkell.toml;

  haskellPackages = haskell.packages.${("ghc" + util.removeDot nixkellConfig.env.ghc)}.override {
    overrides =
      let
        generated = haskell.lib.packagesFromDirectory {
          directory = ./packages;
        };
        manual = _hfinal: hprev: {
          replaceme = haskell.lib.overrideCabal hprev.replaceme (_drv: {
            src = util.filterSrc ../. {
              ignoreFiles = nixkellConfig.ignore.files;
              ignorePaths = nixkellConfig.ignore.paths;
            };
          });
        };
      in
      lib.composeExtensions generated manual;
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
