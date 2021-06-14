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

  # Given a list of pkg names return a list of pkgs 
  getFromPkgs = paths: map (path: lib.getAttrFromPath (lib.splitString "." path) pkgs) paths;

  # Speed up building by disabling a few steps
  leanPkg =
    let
      hl = pkgs.haskell.lib;
    in
    pkg: hl.dontHyperlinkSource (hl.disableLibraryProfiling (hl.dontCoverage (hl.dontHaddock pkg)));
}
