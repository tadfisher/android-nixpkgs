{ stdenv
, lib
, mkGeneric
, autoPatchelfHook
, coreutils
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

  postUnpack = ''
    for f in $(grep -l -a -r "/bin/ls" $out); do
      substituteInPlace $f --replace "/bin/ls" "${coreutils}/bin/ls"
    done
  '';
})
