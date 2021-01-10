{ pkgs ? import <nixpkgs> {}
, channel ? "stable"
}:

with pkgs;

let
  androidSdk = callPackage ./pkgs/android { };
in
rec {
  packages = androidSdk.callPackage (./channels + "/${channel}") { };
  sdk = callPackage ./pkgs/android/sdk.nix { inherit packages; };
}
