{ stdenv, mkGeneric }:

let
  inherit (builtins) filter;
  inherit (stdenv.lib) hasPrefix;

  packages = filter (p: hasPrefix "add-ons;" p.path) (import ./repo/addon.nix);

  mkAddon = p:
    if hasPrefix "add-ons;addon-google_apis" p.path then {
      name = "google-apis-${}"

in listToAttrs (map )
