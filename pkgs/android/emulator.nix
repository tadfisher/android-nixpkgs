{ stdenv, mkGeneric, autoPatchelfHook
, libGL, libX11, libXext, libpulseaudio, zlib }:

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
    libGL
    libX11
    libXext
    libpulseaudio
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
