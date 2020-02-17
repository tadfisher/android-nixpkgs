{ stdenv, mkGeneric, autoPatchelfMultiHook, makeWrapper, findutils
, coreutils, fontconfig, freetype, jdk8, libX11, libXdamage, libXrender
, libXext, libpulseaudio, ncurses5, zlib
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
    for f in $(grep -l -a -r "/bin/ls" $out); do
      substituteInPlace $f --replace "/bin/ls" "${coreutils}/bin/ls"
    done
  '';

  passthru = {
    installSdk = ''
      shopt -s extglob
      for exe in $pkgBase/bin/!(sdkmanager); do
        makeWrapper $exe $out/bin/$(basename $exe) --set JAVA_HOME "${jdk8.home}"
      done
      makeWrapper $pkgBase/bin/sdkmanager $out/bin/sdkmanager \
        --set JAVA_HOME "${jdk8.home}" \
        --set-default ANDROID_HOME $ANDROID_HOME \
        --add-flags '--sdk_root="$ANDROID_HOME"'
    '';
  };
}
