{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  channelNames = [ "stable" "beta" "preview" "canary" ];

  androidSdk = recurseIntoAttrs (callPackage ./pkgs/android {});

  channels = lib.genAttrs channelNames (channel: androidSdk.callPackage (./channels + "/${channel}") {});

in rec {
  packages = recurseIntoAttrs channels;
  sdk = callPackage ./pkgs/android/sdk.nix { inherit packages; };
}
