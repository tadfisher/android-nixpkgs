{ stdenv, mkGeneric, autoPatchelfHook
, fontconfig, freetype, libGL, libX11, libXext, libpulseaudio, libxkbcommon, zlib
, sqlite, nss, nspr }:

package:

let
  libdir = if stdenv.is64bit then "lib64" else "lib";

in

mkGeneric (package // {
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    freetype
    libGL
    libX11
    libXext
    libpulseaudio
    libxkbcommon
    nss
    nspr
    sqlite.out
    zlib
  ];

  runtimeDependencies = [
    stdenv.cc.cc.lib
  ];

  postInstall = ''
    # for emulator-27
    rm -r $out/emulator/${libdir}/gles_mesa 2>/dev/null || true
  '';
})
