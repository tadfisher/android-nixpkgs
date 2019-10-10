{
  pkgs ? import <nixpkgs> {
    overlays = [(self: super: {
      autoPatchelfHook = super.makeSetupHook { name = "auto-patchelf-hook"; }
        ./pkgs/build-support/setup-hooks/auto-patchelf.sh;
      lib = super.stdenv.lib.extend (import ./lib);
    })];
  }
}:

with pkgs;

let
  channelNames = [ "stable" "beta" "preview" "canary" ];

  androidSdk = recurseIntoAttrs (callPackage ./pkgs/android {});

  channels = lib.genAttrs channelNames (channel: androidSdk.callPackage (./channels + "/${channel}") {});

in rec {
  packages = recurseIntoAttrs channels;
  sdk = callPackage ./pkgs/android/sdk.nix { inherit packages; };
}
