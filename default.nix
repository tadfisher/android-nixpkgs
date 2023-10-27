{ pkgs ? import <nixpkgs> { }
, system ? pkgs.stdenv.system
, channel ? "stable"
}:

with pkgs;
let
  androidSdk = callPackage ./pkgs/android { };

  isSupported = _: pkg:
    (!lib.isDerivation pkg) ||
    lib.meta.availableOn hostPlatform pkg ||
    config.allowUnsupportedSystem ||
    builtins.getEnv "NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM" == "1";

  filterIsSupported = lib.filterAttrs isSupported;

  channelPkgs = rec {
    stable = filterIsSupported (androidSdk.callPackage ./channels/stable { });
    beta = filterIsSupported (androidSdk.callPackage ./channels/beta { });
    preview = filterIsSupported (androidSdk.callPackage ./channels/preview { });
    canary = filterIsSupported (androidSdk.callPackage ./channels/canary { });
  };

in
rec {
  packages = channelPkgs."${channel}";
  sdk = callPackage ./pkgs/android/sdk.nix { inherit packages; };
}
