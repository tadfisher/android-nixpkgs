{ stdenv_32bit, mkGeneric, autoPatchelfHook
, ncurses5, zlib, zlib-32}:

package: mkGeneric (package // {
  support32bit = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv_32bit.cc.cc.lib
    ncurses5
    zlib
    zlib-32
  ];
})
