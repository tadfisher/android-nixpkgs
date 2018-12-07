{ mkGeneric, autoPatchelfHook
, ncurses5, zlib, zlib-32}:

package: mkGeneric {
  inherit package;
  pname = "build-tools";
  support32bit = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    ncurses5
    zlib
    zlib-32
  ];
}
