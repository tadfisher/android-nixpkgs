{ stdenv
, lib
, mkGeneric
, makeWrapper
, runCommand
, srcOnly
, autoPatchelfHook
, alsaLib
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
, sqlite
, nss
, nspr
, vulkan-loader
, zlib
}:
let
  systemLibs = [
    "libc++.so"
    "libc++.so.1"
    "libtcmalloc_minimal.so.4"
    "libunwind.so.8"
    "libunwind-x86_64.so.8"
    "qt/lib/libfreetype.so.6"
    "qt/lib/libsoftokn3.so"
    "qt/lib/libsqlite3.so"
    "qt/lib/libxkbcommon.so"
    "qt/lib/libxkbcommon.so.0"
    "qt/lib/libxkbcommon.so.0.0.0"
    "vulkan/libvulkan.so"
    "vulkan/libvulkan.so.1"
  ];

in
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
      nss
      nspr
      sqlite
      vulkan-loader
      zlib
    ];

    dontWrapQtApps = true;

    postUnpack = ''
      rm -r $out/lib64/gles_mesa

      for f in ${toString systemLibs}; do
        rm $out/lib64/$f || true
      done

      # silence LD_PRELOAD warning
      ln -s ${freetype}/lib/libfreetype.so.6 $out/lib64/qt/lib

      # Force XCB platform plugin as Wayland isn't supported.
      # Inject libudev0-shim to fix udev_loader error.
      wrapProgram $out/emulator \
        --set QT_QPA_PLATFORM xcb \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libudev0-shim ]}
    '';
  } // {
  passthru.installSdk = ''
    for exe in emulator emulator-check mksdcard; do
      ln -s $pkgBase/$exe $out/bin/$exe
    done
  '';
})
