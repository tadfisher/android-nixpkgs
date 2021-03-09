{ stdenv
, lib
, mkGeneric
, autoPatchelfHook
, libcxx
, ncurses5
, zlib
}:

mkGeneric {
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libcxx
    ncurses5
    zlib
  ];

  autoPatchelfCCWrappers = [
    stdenv.cc
  ];
}
