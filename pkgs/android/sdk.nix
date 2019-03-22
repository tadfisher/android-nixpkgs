{ stdenv, runCommand, symlinkJoin, androidPackages, jdk }:

pkgsFun:

let
  packages = pkgsFun androidPackages;
  xml = map (p: p.packageXml) packages;

in symlinkJoin {
  name = "android-sdk-env";

  paths = packages ++ xml;

  postBuild = ''
    mkdir -p $out/licenses
    cp -r ${../../repo/licenses}/* $out/licenses/
  '';
}
