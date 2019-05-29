# TODO ndk

{ stdenv, lib, callPackage, fetchurl, androidRepository, packageXml, pkgsi686Linux }:

(androidRepository rec {
    mkGeneric = callPackage ./generic.nix { inherit packageXml; };
    mkBuildTools = callPackage ./build-tools.nix {
      inherit mkGeneric;
      ncurses5-32 = pkgsi686Linux.ncurses5;
      zlib-32 = pkgsi686Linux.zlib;
    };
    mkEmulator = callPackage ./emulator.nix { inherit mkGeneric; };
    mkPlatformTools = callPackage ./platform-tools.nix { inherit mkGeneric; };
    mkPrebuilt = callPackage ./prebuilt.nix { inherit mkGeneric; };
    mkSystemImage = callPackage ./sys-img.nix { inherit mkGeneric; };
    mkTools =
      let
        pkgs32bit = with pkgsi686Linux; {
          fontconfig-32 = fontconfig;
          freetype-32 = freetype;
          libX11-32 = xorg.libX11;
          libXrender-32 = xorg.libXrender;
          zlib-32 = zlib;
        };
      in callPackage ./tools.nix ({ inherit mkGeneric; } // pkgs32bit);
}).packages
