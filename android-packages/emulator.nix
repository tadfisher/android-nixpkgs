{ stdenv, mkGeneric, autoPatchelfHook
, libGL, libX11, libpulseaudio, zlib }:

package: mkGeneric {
  inherit package;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    libGL
    libX11
    libpulseaudio
    zlib
  ];

  runtimeDependencies = [
    stdenv.cc.cc.lib
  ];

  postInstall = ''
    mkdir -p $out/bin
  '';
}
