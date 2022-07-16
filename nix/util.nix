{ pkgs, lib, gitignoreFilter }:
{
  /* Check whether a given list has an element

    > has "b" [ "a" "b" "c" ]
    true
    > has "d" [ "a" "b" "c" ]
    false
  */
  has = e: xs: lib.any (x: x == e) xs;

  /* Remove an element from a list

    > remove "b" ["a" "b" "c"]
    [ "a" "c" ]
    > remove "d" ["a" "b" "c"]
    [ "a" "b" "c" ]
  */
  remove = e: builtins.filter (x: e != x);

  /* Remove dots from strings

    > removeChar "." "9.2.3"
    "923"
  */
  removeChar = c: s: lib.replaceStrings [ c ] [ "" ] s;

  /* Given a package return its derivation

    > getDrv "haskellPackages.implicit-hie"
    «derivation /nix/store/qb9j7iccna81dcs1szwryl4izli95w53-implicit-hie-0.1.2.7.drv»
  */
  getDrv = path: lib.getAttrFromPath (lib.splitString "." path) pkgs;

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

  # Speed up building by disabling a few steps
  leanPkg =
    let
      hl = pkgs.haskell.lib;
    in
    pkg: hl.dontHyperlinkSource (hl.disableLibraryProfiling (hl.dontCoverage (hl.dontHaddock pkg)));
}
