{ stdenv, mkGeneric, autoPatchelfHook
, fontconfig, freetype, libGL, libX11, libXext, libpulseaudio, libxkbcommon, zlib }:

package:

let
  libdir = if stdenv.is64bit then "lib64" else "lib";

in

mkGeneric {
  inherit package;

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
    zlib
  ];

  runtimeDependencies = [
    stdenv.cc.cc.lib
  ];

  postInstall = ''
    # for emulator-27
    rm -r $out/emulator/${libdir}/gles_mesa 2>/dev/null || true
  '';
}
