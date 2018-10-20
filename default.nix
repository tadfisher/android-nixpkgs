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
  androidRepository = import ./repo;

in {
  androidPackages = recurseIntoAttrs (callPackage ./pkgs/android {
    inherit androidRepository;
  });
}
