{ stdenv, lib, runCommand, androidPackages }:

pkgsFun:

let
  inherit (lib) concatMapStringsSep;

  packages = pkgsFun androidPackages;

in runCommand "android-sdk-env" {} ''
  mkdir -p $out/share/android-sdk/licenses
  cp -rL --reflink=auto ${../../repo/licenses}/* $out/share/android-sdk/licenses
  ${concatMapStringsSep "\n" (pkg: ''
    cd ${pkg}/
    find . -type d -exec mkdir -p $out/share/android-sdk/{} \;
    cp -rL --reflink=auto ${pkg}/* $out/share/android-sdk/
  '') packages}
''
