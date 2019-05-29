{ pkgs ? import <nixpkgs> }:

let
  androidPkgs = import ./. {};

in

androidPkgs.sdk.stable (p: with p; [
  tools
  build-tools-28-0-3
  platform-tools
  platforms.android-28
  emulator
  system-images.android-28.google_apis_playstore.x86_64
  system-images.android-Q.google_apis_playstore.x86
])
