# TODO ndk

{ pkgs, pkgsi686Linux, lib }:

lib.makeScope pkgs.newScope (self: with self; rec {
  cc-32 = pkgs.stdenv_32bit.cc;
  fontconfig-32 = pkgsi686Linux.fontconfig;
  freetype-32 = pkgsi686Linux.freetype;
  libX11-32 = pkgsi686Linux.xorg.libX11;
  libXrender-32 = pkgsi686Linux.xorg.libXrender;
  ncurses5-32 = pkgsi686Linux.ncurses5;
  zlib-32 = pkgsi686Linux.zlib;

  autoPatchelfMultiHook = pkgs.makeSetupHook { name = "auto-patchelf-multi-hook"; } ./auto-patchelf.sh;

  fetchandroid = callPackage ./fetch.nix {};

  mkGeneric = callPackage ./generic.nix {};
  mkBuildTools = callPackage ./build-tools.nix {};
  mkCmdlineTools = callPackage ./cmdline-tools.nix {};
  mkEmulator = callPackage ./emulator.nix {};
  mkPlatformTools = callPackage ./platform-tools.nix {};
  mkPrebuilt = callPackage ./prebuilt.nix {};
  mkSrcOnly = callPackage ./src-only.nix {};
  mkTools = callPackage ./tools.nix {};
})
