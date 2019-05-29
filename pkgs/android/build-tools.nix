{ stdenv, stdenv_32bit, lib, mkGeneric, autoPatchelfHook, makeSetupHook, writeShellScript
, ncurses5, ncurses5-32, zlib, zlib-32}:

package: mkGeneric (package // rec {
  support32bit = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv_32bit.cc.cc.lib
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
})
