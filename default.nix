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
  channels = [ "stable" "beta" "preview" "canary" ];

  pkgsFun = channel:
    let
      repoPath = ./channels + "/${channel}";
    in
      recurseIntoAttrs (callPackage ./pkgs/android {
        androidRepository = import repoPath;
        packageXml = repoPath;
      });

  androidPackages =
    lib.genAttrs channels (channel: pkgsFun channel);

  sdkChannels = lib.genAttrs channels
    (channel: callPackage ./pkgs/android/sdk.nix { androidPackages = androidPackages.${channel}; });

in androidPackages // {
  aapt2 = callPackage ./pkgs/aapt2 {};
  sdk = sdkChannels;
}
