{ stdenv, lib, buildEnv, linkFarm, writeText, packages }:

pkgsFun:

let
  inherit (lib) concatStringsSep groupBy' mapAttrs mapAttrsToList unique;

  mkLicenses = paths:
    let
      licenseHashes = groupBy' (sum: p: unique (sum ++ [p.license.hash])) [] (p: p.license.id) paths;
      licenseFiles = mapAttrs (id: hashes: writeText id ("\n" + (concatStringsSep "\n" hashes))) licenseHashes;
    in
      linkFarm "android-licenses" (mapAttrsToList (id: file: { name = id; path = file; }) licenseFiles);

in buildEnv rec {
  name = "android-sdk-env";
  paths = pkgsFun packages;
  extraPrefix = "/share/android-sdk";
  postBuild = ''
    export ANDROID_SDK_HOME=$(mktemp -d)
    touch $ANDROID_SDK_HOME/repositories.cfg

    mkdir -p $out/share/android-sdk
    ln -s ${mkLicenses paths} $out/share/android-sdk/licenses

    $out/share/android-sdk/tools/bin/sdkmanager --sdk_root=$out/share/android-sdk --list --verbose

    mv $out/share/android-sdk/bin $out/bin
  '';
}
