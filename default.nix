{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  channelNames = [ "stable" "beta" "preview" "canary" ];

  androidSdk = recurseIntoAttrs (callPackage ./pkgs/android {});

  channels = lib.genAttrs channelNames (channel:
    let
      packages = androidSdk.callPackage (./channels + "/${channel}") {};
      sdk = callPackage ./pkgs/android/sdk.nix { inherit packages; };
    in packages // { inherit sdk; }
  );

in rec {
  aapt2 = callPackage ./pkgs/aapt2 { };
  packages = recurseIntoAttrs channels;
  sdk = callPackage ./pkgs/android/sdk.nix { inherit packages; };
}
