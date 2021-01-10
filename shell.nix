{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  androidSdkPackages = callPackage ./. { };

  androidSdk = androidSdkPackages.sdk (apkgs: with apkgs.stable; [
    cmdline-tools-latest
    build-tools-30-0-2
    platform-tools
    platforms.android-30
    emulator
  ]);

in
mkShell {
  buildInputs = [
    # Android Studio from nixpkgs.
    android-studio
    androidSdk
  ];
}
