{ stdenv
, lib
, mkGeneric
, makeWrapper
, runCommand
, srcOnly
, autoPatchelfHook
, alsa-lib
, dbus
, fontconfig
, freetype
, gperftools
, libGL
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrender
, libXtst
, libcxx
, libpulseaudio
, libudev0-shim
, libunwind
, libuuid
, libxkbcommon
, ncurses5
, nss
, nspr
, sqlite
, systemd
, vulkan-loader
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
      libX11
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrender
      libXtst
      libcxx
      libpulseaudio
      libxkbcommon
      libudev0-shim
      libunwind
      libuuid
      ncurses5
      nss
      nspr
      sqlite
      zlib
    ];

    dontMoveLib64 = true;
    dontWrapQtApps = true;

    postUnpack = ''
      # Vendored gles_mesa is out of date and causes the following:
      #     LLVM ERROR: Cannot select: intrinsic %llvm.x86.sse41.pblendvb
      #     Segmentation fault (core dumped)
      rm -r $out/lib64/gles_mesa

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
