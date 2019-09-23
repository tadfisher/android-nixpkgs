{ stdenv, mkGeneric, runCommand, srcOnly, autoPatchelfHook
, alsaLib, fontconfig, freetype, gperftools, libGL, libX11, libXcomposite
, libXcursor, libXdamage, libXext, libXfixes, libXi, libXrender, libXtst
, libcxx, libpulseaudio, libunwind, libxkbcommon, sqlite, nss, nspr
, vulkan-loader, zlib
}:

package:

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

mkGeneric (package // {
  nativeBuildInputs = [
    autoPatchelfHook
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
    libunwind
    nss
    nspr
    sqlite
    vulkan-loader
    zlib
  ];

  dontWrapQtApps = true;

  postInstall = ''
    rm -r $out/emulator/lib64/gles_mesa

    for f in ${toString systemLibs}; do
      rm $out/emulator/lib64/$f || true
    done

    # silence LD_PRELOAD warning
    ln -s ${freetype}/lib/libfreetype.so.6 $out/emulator/lib64/qt/lib
  '';
})
