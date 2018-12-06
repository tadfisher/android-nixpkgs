# TODO ndk

{ stdenv, lib, callPackage, fetchurl, androidRepository, pkgsi686Linux }:

let
  inherit (builtins) any attrValues elem filter hasAttr head match length listToAttrs
    replaceStrings split compareVersions;

  inherit (lib) concatStringsSep count foldr hasPrefix init last
    prefixedBy range suffixedBy versionAsPath
    mapAttrsRecursiveCond
    recursiveUpdate removePrefix setAttrByPath sublist;

  standalonePaths =
    let
      withoutVersions =
        filter (path: match "[[:digit:]].*" (last (split ";" path)) == null)
               (map (p: p.path) androidRepository);
    in
      filter (path: count (x: x == path) withoutVersions == 1) withoutVersions;

  packages = foldr (p: attrs:
    let
      path = filter (x: x != []) (split ";" p.path);
      merged = if match "[[:digit:]].*" (last path) != null
        then (sublist 0 ((length path) - 2) path) ++ [ "${last (init path)}-${versionAsPath (last path)}"]
        else (init path) ++ [ "${last path}-${versionAsPath p.revision}"];
    in
      if elem p.path standalonePaths
      then recursiveUpdate attrs (setAttrByPath path p)
      else recursiveUpdate attrs (setAttrByPath merged p)
  ) {} androidRepository;

  mkGeneric = callPackage ./generic.nix {};

  mkBuildTools = callPackage ./build-tools.nix { inherit mkGeneric; };
  mkEmulator = callPackage ./emulator.nix { inherit mkGeneric; };
  mkPlatformTools = callPackage ./platform-tools.nix { inherit mkGeneric; };
  mkPrebuilt = callPackage ./prebuilt.nix { inherit mkGeneric; };
  mkSystemImage = callPackage ./sys-img.nix { inherit mkGeneric; };

  mkTools =
    let
      pkgs32bit = with pkgsi686Linux; {
        fontconfig-32 = fontconfig;
        freetype-32 = freetype;
        libX11-32 = xorg.libX11;
        libXrender-32 = xorg.libXrender;
        zlib-32 = zlib;
      };
    in callPackage ./tools.nix ({ inherit mkGeneric; } // pkgs32bit);

  prebuilts = [ "cmake" "lldb" ];

  findBuilder = path: package:
    /**/ if hasPrefix "build-tools;" package.path then mkBuildTools
    else if package.path == "emulator" then mkEmulator
    else if package.path == "platform-tools" then mkPlatformTools
    else if package.path == "tools" then mkTools
    else if hasPrefix "system-images" package.path then mkSystemImage
    else if any (prebuilt: hasPrefix prebuilt package.path) prebuilts then mkPrebuilt
    else p: mkGeneric { package = p; };

  androidPackages = mapAttrsRecursiveCond
    (as: !(as ? path))
    (path: package: let build = findBuilder path package; in build package)
    packages;

  findLatest = prefix: packages:
    foldr (a: b: if compareVersions a.version b.version > 0 then a else b)
          { version = "0"; }
          (filter (p: p ? name && hasPrefix prefix p.name) (attrValues packages));

  findLatestMajors = prefix: majors: packages:
    foldr (v: attrs: attrs // { "${prefix}-${toString v}" = findLatest "${prefix}-${toString v}" packages; }) {} majors;

in recursiveUpdate androidPackages ({
  build-tools = findLatest "build-tools" androidPackages;
  emulator = findLatest "emulator" androidPackages;
  ndk-bundle = findLatest "ndk-bundle" androidPackages;
  platform-tools = findLatest "platform-tools" androidPackages;
  platforms = androidPackages.platforms // {
    android = findLatest "android" androidPackages.platforms;
  };
  tools = findLatest "tools" androidPackages;
} // (findLatestMajors "build-tools" (range 17 28) androidPackages))
