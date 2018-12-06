{ pkgs ? import <nixpkgs> }:

let
  androidPkgs = import ../. {};

  sdk = androidPkgs.sdk (p: with p; [
    tools
    build-tools
    platform-tools
    platforms.android-28
    emulator
    system-images.android-28.google_apis_playstore.x86_64
  ]);

in sdk
