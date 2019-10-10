{ stdenv, mkGeneric, autoPatchelfHook, makeWrapper, findutils
, coreutils, fontconfig, freetype, libX11, libXdamage, libXrender
, libXext, libpulseaudio, ncurses5, zlib, jdk8
# 32-bit dependencies
, fontconfig-32, freetype-32, libX11-32, libXrender-32, zlib-32
}:

mkGeneric {
  nativeBuildInputs = [
    autoPatchelfHook
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
    jdk8
    fontconfig-32
    freetype-32
    libX11-32
    libXrender-32
    zlib-32
  ];

  postInstall = ''
    for f in $(grep -l -a -r "/bin/ls" $out/tools); do
      substituteInPlace $f --replace "/bin/ls" "${coreutils}/bin/ls"
    done

    wrapProgram $out/tools/bin/sdkmanager --set JAVA_HOME ${jdk8}

    mkdir -p $out/bin
    ln -s $out/tools/bin/* $out/bin
  '';
}
