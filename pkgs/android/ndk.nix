{ lib
, stdenv
, mkGeneric
, autoPatchelfHook
, makeWrapper
, pkgs
, pkgsHostHost
}:

package:

let
  runtimePaths = lib.makeBinPath (with pkgsHostHost; [
    coreutils
    file
    findutils
    gawk
    gnugrep
    gnused
    jdk
    python3
  ]);

  buildArgs = lib.optionalAttrs stdenv.isLinux
    {
      nativeBuildInputs = [
        autoPatchelfHook
        makeWrapper
      ];

      buildInputs = with pkgs; [
        glibc
        libcxx.out
        libxml2
        ncurses5
        stdenv.cc.cc
        zlib
        (if lib.versionAtLeast package.version "23" then python3 else python27)
      ];

      autoPatchelfCCWrappers = [
        stdenv.cc
      ];

      patches = lib.optional (lib.versionOlder package.version "21")
        ./make_standalone_toolchain.py_18.patch;

      postInstall = ''
        if [ -d $out/toolchains/renderscript/prebuilt/linux-x86_64/lib64 ]; then
          addAutoPatchelfSearchPath $out/toolchains/renderscript/prebuilt/linux-x86_64/lib64
        fi

        if [ -d $out/toolchains/llvm/prebuilt/linux-x86_64/lib64 ]; then
          addAutoPatchelfSearchPath $out/toolchains/llvm/prebuilt/linux-x86_64/lib64
        fi

        find $out/toolchains -type d -name bin -or -name lib64 | while read dir; do
          autoPatchelf "$dir"
        done

        # fix ineffective PROGDIR / MYNDKDIR determination
        sed -i -e 's|^PROGDIR=`dirname $0`|PROGDIR=`dirname $(readlink -f $(which $0))`|' $out/ndk-build

        autoPatchelf $out/prebuilt/linux-x86_64

        wrapProgram $out/ndk-build --prefix PATH : "${runtimePaths}"
      '';

      dontStrip = true;
      dontPatchELF = true;
      dontAutoPatchelf = true;
      autoPatchelfIgnoreMissingDeps = true;
    } // {
    passthru.installSdk = ''
      ln -sf $pkgBase/ndk-build $out/bin/ndk-build
    '';
  };

in
mkGeneric buildArgs package
