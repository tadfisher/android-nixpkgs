{ stdenv, mkGeneric, autoPatchelfHook, python }:

package: mkGeneric (package // {
  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    python
  ];

  runtimeDependencies = [
    stdenv.cc.cc.lib
  ];

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/platform-tools/{adb,fastboot} $out/bin/
  '';
})
