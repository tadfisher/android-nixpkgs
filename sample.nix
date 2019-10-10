{ pkgs ? import <nixpkgs> }:

let
  androidPkgs = import ./. {};

in

androidPkgs.sdk (p: with p.stable; [
  tools
  build-tools-29-0-0
  platform-tools
  platforms.android-29
  emulator
  system-images.android-29.google-apis-playstore.x86
])
