{ stdenv, mkGeneric
, autoPatchelfHook
}:

let
  inherit (stdenv.lib) findSingle foldr hasPrefix split;

  packages = filter (p: hasPrefix "extras;" p.path) (import ./repo/addon.nix);

  packageAttrs = foldr (p: attrs:
    let
      paths = split ";" package.path;

  )

in {

  android.m2repository = mkGeneric {
    package = findSingle
  }
}
