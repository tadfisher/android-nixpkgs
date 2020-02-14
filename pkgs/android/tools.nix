{ stdenv, mkGeneric, autoPatchelfMultiHook, makeWrapper, findutils
, coreutils, fontconfig, freetype, libX11, libXdamage, libXrender
, libXext, libpulseaudio, ncurses5, zlib, jdk
# 32-bit dependencies
, stdenv_32bit, fontconfig-32, freetype-32, libX11-32, libXrender-32, zlib-32
}:

mkGeneric {
  nativeBuildInputs = [
    autoPatchelfMultiHook
    findutils
    makeWrapper
  ];

  buildInputs = [
    coreutils
    fontconfig
    freetype
    libX11
    libXdamage
    libXrender
    libXext
    libpulseaudio
    ncurses5
    jdk
    stdenv_32bit.cc.cc.lib
    fontconfig-32
    freetype-32
    libX11-32
    libXrender-32
    zlib-32
  ];

  autoPatchelfCCWrappers = [
    stdenv.cc
    stdenv_32bit.cc
  ];

  postUnpack = ''
    for f in $(grep -l -a -r "/bin/ls" $packageBase); do
      substituteInPlace $f --replace "/bin/ls" "${coreutils}/bin/ls"
    done

    wrapProgram $packageBase/bin/sdkmanager --set-default JAVA_HOME ${jdk.home}

    mkdir -p $out/bin
    ln -s $out/tools/bin/* $out/bin
  '';
}
