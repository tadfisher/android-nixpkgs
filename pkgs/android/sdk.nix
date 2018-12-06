{ stdenv, runCommand, symlinkJoin, androidPackages, jdk }:

pkgsFun:

symlinkJoin {
  name = "android-sdk-env";
  paths = pkgsFun androidPackages;
  postBuild = ''
    mkdir -p $out/licenses
    cp -r ${../../repo/licenses}/* $out/licenses/
  '';
}
