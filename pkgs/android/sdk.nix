{ stdenv, buildEnv, androidPackages }:

pkgsFun:

buildEnv {
  name = "android-sdk-env";
  paths = pkgsFun androidPackages;
}
