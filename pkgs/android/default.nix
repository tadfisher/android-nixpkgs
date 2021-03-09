# TODO ndk

{ pkgs, lib }:

lib.makeScope pkgs.newScope (self: with self; rec {
  fetchandroid = callPackage ./fetch.nix { };
  mkGeneric = callPackage ./generic.nix { };
  mkBuildTools = callPackage ./build-tools.nix { };
  mkCmdlineTools = callPackage ./cmdline-tools.nix { };
  mkEmulator = callPackage ./emulator.nix { };
  mkPlatformTools = callPackage ./platform-tools.nix { };
  mkPrebuilt = callPackage ./prebuilt.nix { };
  mkSrcOnly = callPackage ./src-only.nix { };
  mkTools = callPackage ./tools.nix { };
})
