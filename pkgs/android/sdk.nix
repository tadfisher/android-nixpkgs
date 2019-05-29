{ stdenv, lib, buildEnv, runCommand, androidPackages }:

pkgsFun:

let
  inherit (lib) concatMapStringsSep;

  packages = pkgsFun androidPackages;

in buildEnv {
  name = "android-sdk-env";
  paths = packages;
  extraPrefix = "/share/android-sdk";
  postBuild = ''
    mkdir -p $out/share/android-sdk/licenses
    cp -rL ${../../repo/licenses}/* $out/share/android-sdk/licenses

    $out/share/android-sdk/tools/bin/sdkmanager --sdk_root=$out/share/android-sdk --list --verbose

    mv $out/share/android-sdk/bin $out/bin
  '';
}
