{ stdenv, lib, mkGeneric, autoPatchelfHook, makeSetupHook
, ncurses5, ncurses5-32, zlib, zlib-32}:

package: mkGeneric (rec {
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    ncurses5
    ncurses5-32
    zlib
    zlib-32
  ];

  dontAutoPatchelf =
    builtins.compareVersions package.version "18.0.1" >= 0 &&
    builtins.compareVersions package.version "25.0.3" <= 0;

  postInstall = lib.optionalString dontAutoPatchelf ''
    addAutoPatchelfSearchPath "$packageBase"
    autoPatchelf --no-recurse "$packageBase"
  '';
}) package
