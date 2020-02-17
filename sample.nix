{ pkgs ? import <nixpkgs> }:

let
  androidPkgs = import ./. {};

in

androidPkgs.sdk (p: with p.stable; [
  tools
  build-tools-29-0-3
  platform-tools
  platforms.android-29
  emulator
])
