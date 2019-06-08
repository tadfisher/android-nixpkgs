{ pkgs ? import <nixpkgs> }:

let
  androidPkgs = import ./. {};

in

androidPkgs.sdk.stable (p: with p; [
  tools
  build-tools-29-0-0
  platform-tools
  platforms.android-29
  emulator
  system-images.android-29.google_apis_playstore.x86
])
