{ stdenv, mkGeneric, autoPatchelfHook, python }:

mkGeneric {
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    python
  ];

  runtimeDependencies = [
    stdenv.cc.cc.lib
  ];

  postUnpack = ''
    mkdir -p $out/bin
    ln -s $packageBase/{adb,fastboot} $out/bin/
  '';
}
