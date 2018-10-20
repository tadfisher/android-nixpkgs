# TODO ndk

{ stdenv, lib, callPackage, fetchurl, androidRepository }:

let
  inherit (builtins) filter hasAttr head match length listToAttrs
    replaceStrings split;

  inherit (lib) concatStringsSep foldr hasPrefix init last
    prefixedBy suffixedBy versionAsPath
    mapAttrsRecursiveCond
    recursiveUpdate removePrefix setAttrByPath sublist;

  packages = foldr (p: attrs:
    let
      path = filter (x: x != []) (split ";" p.path);
      merged = if match "[[:digit:]].*" (last path) != null
        then (sublist 0 ((length path) - 2) path) ++ [ "${last (init path)}-${versionAsPath (last path)}"]
        else (init path) ++ [ "${last path}-${versionAsPath p.revision}"];
    in
      recursiveUpdate attrs (setAttrByPath merged p)
  ) {} androidRepository;

  mkGeneric = callPackage ./generic.nix {};

  mkBuildTools = callPackage ./build-tools.nix { inherit mkGeneric; };
  mkEmulator = callPackage ./emulator.nix { inherit mkGeneric; };
  mkPlatformTools = callPackage ./platform-tools.nix { inherit mkGeneric; };
  mkTools = callPackage ./tools.nix { inherit mkGeneric; };

  findBuilder = path: package:
    if (hasPrefix "build-tools;" package.path) then mkBuildTools
    else if (package.path == "emulator") then mkEmulator
    else if (package.path == "platform-tools") then mkPlatformTools
    else if (package.path == "tools") then mkTools
    else (p: mkGeneric { package = p; });

in

mapAttrsRecursiveCond
  (as: !(hasAttr "path" as))
  (path: package: let build = findBuilder path package; in build package)
  packages
