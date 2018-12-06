{
  pkgs ? import <nixpkgs> {
    overlays = [(self: super: {
      autoPatchelfHook = super.makeSetupHook {
        name = "auto-patchelf-hook";
        substitutions = rec {
          ld = "${super.stdenv.cc}/nix-support/dynamic-linker";
          ld32 = if super.stdenv.hostPlatform.is32bit then ld
            else "${super.stdenv_32bit.cc}/nix-support/dynamic-linker-m32";
        }; }
        ./pkgs/build-support/setup-hooks/auto-patchelf.sh;
      lib = super.stdenv.lib.extend (import ./lib);
    })];
  }
}:

with pkgs;

let
  androidRepository = import ./repo;
  androidPackages = recurseIntoAttrs (callPackage ./pkgs/android {
    inherit androidRepository;
  });

in androidPackages // {
  androidSdk = callPackage ./pkgs/android/sdk.nix { inherit androidPackages; };
}
