{ stdenv
, lib
, mkGeneric
, autoPatchelfHook
, makeWrapper
, findutils
, coreutils
, fontconfig
, freetype
, jdk8
, libX11
, libXdamage
, libXrender
, libXext
, libpulseaudio
, ncurses5
, zlib
}:

mkGeneric (lib.optionalAttrs stdenv.isLinux {
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
  ];

  postUnpack = ''
    for f in $(grep -l -a -r "/bin/ls" $out); do
      substituteInPlace $f --replace "/bin/ls" "${coreutils}/bin/ls"
    done
  '';
} // {
  passthru.installSdk = ''
    shopt -s extglob
    for exe in $pkgBase/bin/!(sdkmanager); do
      makeWrapper $exe $out/bin/$(basename $exe) --set JAVA_HOME "${jdk8.home}"
    done
    makeWrapper $pkgBase/bin/sdkmanager $out/bin/sdkmanager \
      --set JAVA_HOME "${jdk8.home}" \
      --set-default ANDROID_HOME $ANDROID_HOME \
      --add-flags '--sdk_root="$ANDROID_HOME"'
  '';
})
