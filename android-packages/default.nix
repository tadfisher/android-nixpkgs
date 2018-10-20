# TODO ndk

{ stdenv, callPackage, fetchurl }:

let
  inherit (builtins) filter hasAttr head listToAttrs split replaceStrings;
  inherit (stdenv.lib) concatStringsSep foldr hasPrefix removePrefix;

  repository = import ./repo/repository.nix;
  addonRepository = import ./repo/addon.nix;

  mkGeneric = callPackage ./generic.nix {};

  mkBuildTools = callPackage ./build-tools.nix { inherit mkGeneric; };
  mkEmulator = callPackage ./emulator.nix { inherit mkGeneric; };
  mkPlatformTools = callPackage ./platform-tools.nix { inherit mkGeneric; };
  mkTools = callPackage ./tools.nix { inherit mkGeneric; };

in rec {
  addons = listToAttrs (map (p: {
    name = replaceStrings ["_" "-google-"] ["-" "-"] (removePrefix "add-ons;addon-" p.path);
    value = mkGeneric { package = p; };
  }) (filter (p: (hasPrefix "add-ons;" p.path) && (! hasAttr "obsolete" p)) addonRepository));

  buildTools = listToAttrs (map (p: {
    name = replaceStrings ["." ";"] ["-" "-"] p.path;
    value = mkBuildTools p;
  }) (filter (p: hasPrefix "build-tools;" p.path) repository))
  // { latest = buildTools.build-tools-28-0-3; };

  emulators = listToAttrs (map (p: {
      name = "emulator-${head (split "\\." p.revision)}";
      value = mkEmulator p;
  }) (filter (p: p.path == "emulator") repository))
  // { latest = emulators.emulator-28; };

  extras = callPackage ./extras.nix { inherit mkGeneric; };

  platforms = listToAttrs (map (p: {
    name = removePrefix "platforms;" p.path;
    value = mkGeneric { package = p; };
  }) (filter (p: hasPrefix "platforms;" p.path) repository))
  // { latest = platforms.android-28; };

  platformTools = listToAttrs (map (p:
    let pkg = mkPlatformTools p; in {
      name = replaceStrings ["." ";"] ["-" "-"] pkg.name;
      value = pkg;
    }) (filter (p: p.path == "platform-tools") repository))
  // { latest = platformTools.platform-tools-28-0-1; };

  sources = listToAttrs (map (p: {
    name = removePrefix "sources;" p.path;
    value = mkGeneric { package = p; };
  }) (filter (p: hasPrefix "sources;" p.path) repository))
  // { latest = sources.android-28; };

  systemImages = callPackage ./system-images.nix { inherit mkGeneric; };

  tools = listToAttrs (map (p: let pkg = mkTools p; in {
    name = "${replaceStrings ["."] ["-"] pkg.name}";
    value = pkg;
  }) (filter (p: p.path == "tools") repository))
  // { latest = tools.tools-26-1-1; };
}
