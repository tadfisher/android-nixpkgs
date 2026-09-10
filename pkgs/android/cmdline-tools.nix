{
  stdenv,
  lib,
  autoPatchelfHook,
  mkGeneric,
  openjdk,
  jdk ? openjdk,
  android-cli ? null,
}:

pkg:

let
  # cmdline-tools 23 deprecated the sdkmanager tool, so it's now a shim around the 'android' binary.
  # 'android' is a bootstrapper: on first run it downloads 'android-cli' from dl.google.com into
  # $ANDROID_USER_HOME/bin, which then extracts its own embedded copy of sdklib and a bundled JRE.
  # This is _not_ likely to work on NixOS without nix-ld or a FHS wrapper for android-cli.
  bootstrapsAndroidCli = lib.versionAtLeast pkg.version "23";

  useNixpkgsAndroidCli =
    bootstrapsAndroidCli && android-cli != null && lib.meta.availableOn stdenv.hostPlatform android-cli;

  patchBootstrapper = bootstrapsAndroidCli && !useNixpkgsAndroidCli && stdenv.hostPlatform.isLinux;

in
mkGeneric (
  {
    pname = "cmdline-tools";

    passthru.installSdk = ''
      chmod +w $pkgBase/bin
      for script in $pkgBase/bin/*; do
        wrapProgram $script \
          --set-default JAVA_HOME "${jdk.home}" \
          --set-default ANDROID_SDK_ROOT $ANDROID_SDK_ROOT \
          --prefix JAVA_OPTS ' ' "-Dcom.android.sdklib.toolsdir=$pkgBase" \
          --prefix JAVA_OPTS ' ' "-Dcom.android.sdkmanager.toolsdir=$pkgBase" \
          --prefix JAVA_OPTS ' ' "-Dcom.android.tools.lint.bindir=$pkgBase"
        ln -rvs $script $out/bin/$(basename $script)
      done
      chmod -w $pkgBase/bin
    '';
  }
  // lib.optionalAttrs useNixpkgsAndroidCli {
    postFixup = ''
      ln -sf ${lib.getExe android-cli} $out/bin/android
    '';
  }
  // lib.optionalAttrs patchBootstrapper {
    nativeBuildInputs = [
      autoPatchelfHook
    ];

    postFixup = ''
      autoPatchelf "$out/bin"
    '';
  }
) pkg
