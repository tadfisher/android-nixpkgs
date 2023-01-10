{ lib
, stdenv
, mkGeneric
, makeWrapper
, pkgsHostHost
, autoPatchelfHook ? null
, libedit ? null
, libxcrypt ? null
, ncurses5 ? null
, openssl ? null
, sqlite ? null
, python27 ? null
, zlib ? null
}:

assert stdenv.isLinux -> autoPatchelfHook != null;
assert stdenv.isLinux -> libxcrypt != null;
assert stdenv.isLinux -> ncurses5 != null;
assert stdenv.isLinux -> zlib != null;

package:

let
  versionMajor = builtins.head (builtins.splitVersion package.version);
in

assert (stdenv.isLinux && lib.versionOlder versionMajor "18") -> libedit != null;
assert (stdenv.isLinux && versionMajor == "16") -> openssl != null;
assert (stdenv.isLinux && versionMajor == "16") -> sqlite != null;

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
    which
  ]);

  searchPaths = [
    "prebuilt/linux-x86_64/lib"
    "toolchains/renderscript/prebuilt/linux-x86_64/lib64"
    "toolchains/llvm/prebuilt/linux-x86_64/lib"
    "toolchains/llvm/prebuilt/linux-x86_64/lib64"
    "toolchains/llvm/prebuilt/linux-x86_64/python3/lib"
  ];

  buildArgs = {
    nativeBuildInputs = [
      makeWrapper
    ] ++ lib.optionals stdenv.isLinux [
      autoPatchelfHook
    ];

    buildInputs = lib.optionals stdenv.isLinux ([
      libxcrypt
      ncurses5
      zlib
    ] ++ lib.optionals (lib.versionOlder versionMajor "20") [
      stdenv.cc.cc.lib
    ] ++ lib.optionals (lib.versionOlder versionMajor "18") [
      libedit
    ] ++ lib.optionals (versionMajor == "16") [
      python27
    ]);

    postInstall = ''
      patchShebangs .

      ${lib.optionalString (stdenv.isLinux && lib.versionOlder versionMajor "18") ''
      ln -sf ${libedit}/lib/libedit.so $out/toolchains/llvm/prebuilt/linux-x86_64/lib64/libedit.so.2
      ''}

      ${lib.optionalString (stdenv.isLinux && versionMajor == "16") ''
      rm -rf $out/prebuilt/*/lib/python2.7
      ''}

      ${lib.optionalString (stdenv.isLinux) ''
      for path in ${toString searchPaths}; do
        addAutoPatchelfSearchPath "$out/$path"
      done
      find $out/toolchains -type d -name bin -or -name lib64 | while read dir; do
        autoPatchelf "$dir"
      done
      # Patch executables
      if [ -d $out/prebuilt/linux-x86_64 ]; then
         autoPatchelf $out/prebuilt/linux-x86_64
      fi
      ''}

      # fix ineffective PROGDIR / MYNDKDIR determination
      sed -i -e 's|^PROGDIR=`dirname $0`|PROGDIR=`dirname $(readlink -f $(which $0))`|' $out/build/ndk-build

      wrapProgram $out/ndk-build --prefix PATH : "${runtimePaths}"
    '';

    dontStrip = true;
    dontPatchELF = true;
    dontAutoPatchelf = true;
    autoPatchelfIgnoreMissingDeps = [ "liblog.so" ];
  } // {
    passthru.installSdk = ''
      ln -sf $pkgBase/ndk-build $out/bin/ndk-build
    '';
  };

in
mkGeneric buildArgs package
