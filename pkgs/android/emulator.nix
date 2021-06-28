{ stdenv
, lib
, mkGeneric
, makeWrapper
, runCommand
, srcOnly
, autoPatchelfHook
, alsaLib
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
, swiftshader
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
      alsaLib
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
      swiftshader
      vulkan-loader
      zlib
    ];

    dontMoveLib64 = true;
    dontWrapQtApps = true;

    postUnpack = ''
      rm -r $out/lib64/gles_mesa
      rm -r $out/lib64/vulkan/*
      ln -s $(realpath ${vulkan-loader}/lib/libvulkan.so.1) $out/lib64/vulkan/libvulkan.so.1
      ln -s ${swiftshader}/lib/libEGL.so $out/lib64/vulkan/
      ln -s ${swiftshader}/lib/libvk_swiftshader.so $out/lib64/vulkan/
      ln -s ${swiftshader}/share/vulkan/icd.d/vk_swiftshader_icd.json $out/lib64/vulkan/

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
