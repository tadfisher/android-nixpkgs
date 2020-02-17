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

  passthru = {
    installSdk = ''
      for exe in adb dmtracedump e2fsdroid etc1tool fastboot hprof-conv make_f2fs mke2fs sload_f2fs; do
        ln -s $pkgBase/$exe $out/bin/$exe
      done

      ln -s $pkgBase/systrace/systrace.py $out/bin/systrace
    '';
  };
}
