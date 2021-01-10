{ pkgs ? import <nixpkgs> }:

let
  androidPkgs = import ./. {};

in

androidPkgs.sdk (p: with p.stable; [
  cmdline-tools-latest
  build-tools-30-0-2
  platform-tools
  platforms-android-30
  emulator
])
