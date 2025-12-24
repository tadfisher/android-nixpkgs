{ stdenv
, lib
, mkGeneric
, makeWrapper
, autoPatchelfHook
, alsa-lib
, dbus
, fontconfig
, freetype
, gperftools
, libGL
, libICE
, libSM
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrender
, libXtst
, libbsd
, libcxx
, libdrm
, libpulseaudio
, libtiff
, libudev0-shim
, libunwind
, libuuid
, libxkbcommon
, libxkbfile
, ncurses5
, nss
, nspr
, sqlite
, systemd
, waylandpp
, xkeyboard_config
, zlib
}:

mkGeneric (lib.optionalAttrs stdenv.isLinux
  {
    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [
      alsa-lib
      fontconfig
      freetype
      gperftools
      libGL
      libICE
      libSM
      libX11
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrender
      libXtst
      libbsd
      libcxx
      libdrm
      libpulseaudio
      libtiff
      libudev0-shim
      libunwind
      libuuid
      libxkbcommon
      libxkbfile
      ncurses5
      nss
      nspr
      sqlite
      waylandpp.lib
      zlib
    ];

    dontMoveLib64 = true;
    dontWrapQtApps = true;

    postUnpack = ''
      addAutoPatchelfSearchPath $packageBaseDir/lib
      addAutoPatchelfSearchPath $packageBaseDir/lib64
      addAutoPatchelfSearchPath $packageBaseDir/lib64/qt/lib

      # Needs libtiff.so.5, but nixpkgs provides libtiff.so.6
      patchelf --replace-needed libtiff.so.5 libtiff.so \
        $out/lib64/qt/plugins/imageformats/libqtiffAndroidEmu.so

      # Force XCB platform plugin as Wayland isn't supported.
      # Inject libudev0-shim to fix udev_loader error.
      wrapProgram $out/emulator \
        --set QT_QPA_PLATFORM xcb \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
          libudev0-shim
          dbus
          systemd
        ]} \
        --set QT_XKB_CONFIG_ROOT ${xkeyboard_config}/share/X11/xkb \
        --set QTCOMPOSE ${libX11.out}/share/X11/locale
    '';
  } // {
  passthru.installSdk = ''
    for exe in emulator emulator-check mksdcard; do
      ln -s $pkgBase/$exe $out/bin/$exe
    done
  '';
})
