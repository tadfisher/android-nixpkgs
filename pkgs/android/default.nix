# TODO ndk

{ pkgs, pkgsi686Linux, lib }:

lib.makeScope pkgs.newScope (self: with self; rec {
  fontconfig-32 = pkgsi686Linux.fontconfig;
  freetype-32 = pkgsi686Linux.freetype;
  libX11-32 = pkgsi686Linux.xorg.libX11;
  libXrender-32 = pkgsi686Linux.xorg.libXrender;
  ncurses5-32 = pkgsi686Linux.ncurses5;
  zlib-32 = pkgsi686Linux.zlib;

  fetchandroid = callPackage ./fetch.nix {};

  mkGeneric = callPackage ./generic.nix {};
  mkBuildTools = callPackage ./build-tools.nix {
    stdenv = pkgs.stdenv_32bit;
    mkGeneric = mkGeneric.override {
      stdenv = pkgs.stdenv_32bit;
    };
  };
  mkEmulator = callPackage ./emulator.nix {};
  mkPlatformTools = callPackage ./platform-tools.nix {};
  mkPrebuilt = callPackage ./prebuilt.nix {};
  mkSrcOnly = callPackage ./src-only.nix {};
  mkSystemImage = callPackage ./sys-img.nix {};
  mkTools = callPackage ./tools.nix {
    stdenv = pkgs.stdenv_32bit;
    mkGeneric = mkGeneric.override {
      stdenv = pkgs.stdenv_32bit;
    };
  };
})
