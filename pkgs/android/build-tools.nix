{ mkGeneric, autoPatchelfHook
, ncurses5, zlib, zlib-32}:

package: mkGeneric (package // {
  support32bit = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    ncurses5
    zlib
    zlib-32
  ];
})
