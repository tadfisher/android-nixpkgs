{ stdenv
, lib
, makeWrapper
, mkGeneric
, autoPatchelfHook
, coreutils
, jdk
, libcxx
, ncurses5
, zlib
}:

mkGeneric (lib.optionalAttrs stdenv.isLinux {
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
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
    for f in apksigner d8 lld; do
      substituteInPlace "$out/$f" --replace "/bin/ls" "ls"
      wrapProgram "$out/$f" --set PATH ${lib.makeBinPath [coreutils jdk]}
    done
  '';
})
