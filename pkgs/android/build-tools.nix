{ stdenv, stdenv_32bit, lib, mkGeneric, autoPatchelfMultiHook
, ncurses5, ncurses5-32, zlib, zlib-32}:

mkGeneric {
  nativeBuildInputs = [
    autoPatchelfMultiHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    stdenv_32bit.cc.cc.lib
    ncurses5
    ncurses5-32
    zlib
    zlib-32
  ];

  autoPatchelfCCWrappers = [
    stdenv.cc
    stdenv_32bit.cc
  ];
}
