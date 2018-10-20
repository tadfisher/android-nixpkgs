{ mkGeneric, autoPatchelfHook, ncurses5, zlib}:

package: mkGeneric {
  inherit package;
  pname = "build-tools";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    ncurses5
    zlib
  ];
}
