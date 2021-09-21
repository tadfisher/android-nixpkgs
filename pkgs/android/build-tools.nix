{ stdenv
, lib
, mkGeneric
, autoPatchelfHook
, libcxx
, ncurses5
, zlib
}:

mkGeneric (lib.optionalAttrs stdenv.isLinux {
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libcxx
    ncurses5
    zlib
  ];

  autoPatchelfIgnoreMissingDeps = true;

  autoPatchelfCCWrappers = [
    stdenv.cc
  ];
})
