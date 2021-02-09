{ pkgs }: with pkgs;
let
  config = lib.importTOML ../nixkell.toml;

  haskellPackages = haskell.packages.${("ghc" + util.removeDot config.env.ghc)}.override {
    overrides =
      let
        generated = haskell.lib.packagesFromDirectory {
          directory = ./packages;
        };
        manual = _hfinal: hprev: {
          replaceme = haskell.lib.overrideCabal hprev.replaceme (_drv: {
            src = util.filterSrc ../. {
              ignoreFiles = config.ignore.files;
              ignorePaths = config.ignore.paths;
            };
          });
        };
      in
      lib.composeExtensions generated manual;
  };

  ghc = haskellPackages.ghc.withPackages (_ps:
    haskell.lib.getHaskellBuildInputs haskellPackages.replaceme
  );
in
{
  bin = haskellPackages.replaceme;

  shell = buildEnv {
    name = "replaceme-env";
    paths = util.getFrom pkgs config.env.packages;
  };
}
