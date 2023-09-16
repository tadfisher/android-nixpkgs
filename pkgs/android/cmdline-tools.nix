{ mkGeneric, openjdk, jdk ? openjdk }:

mkGeneric
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
