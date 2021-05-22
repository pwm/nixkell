{ pkgs, lib, gitignoreFilter }:
{
  # Remove dots from strings
  removeDot = s: lib.replaceStrings [ "." ] [ "" ] s;

  # Filter .gitignore as well as files and paths ignored in the nixkell config
  filterSrc = path: { ignoreFiles ? [ ], ignorePaths ? [ ] }:
    lib.cleanSourceWith {
      src = path;
      filter =
        let
          srcIgnored = gitignoreFilter path; # in let binding to memoize
          relToPath = lib.removePrefix (toString path + "/");
        in
        path: type:
          srcIgnored path type
          && ! builtins.elem (baseNameOf path) ignoreFiles
          && ! lib.any (d: lib.hasPrefix d (relToPath path)) ignorePaths;
    };

  # Build with our haskell instead of the stock for selected packages
  buildWith = ourHaskell: names: paths: map
    (path:
      let fNames = lib.filter (name: lib.hasSuffix name path) names;
      in
      if fNames != [ ]
      then ourHaskell.${(builtins.head fNames)}
      else lib.getAttrFromPath (lib.splitString "." path) pkgs
    )
    paths;

  # Speed up building by disabling a few steps
  leanPkg =
    let
      hl = pkgs.haskell.lib;
    in
    pkg: hl.dontHyperlinkSource (hl.disableLibraryProfiling (hl.dontCoverage (hl.dontHaddock pkg)));
}
