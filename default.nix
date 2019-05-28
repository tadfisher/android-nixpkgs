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
  pkgsFun = channel:
    let
      repoPath = ./channels + "/${channel}";
    in
      recurseIntoAttrs (callPackage ./pkgs/android {
        androidRepository = import repoPath;
        packageXml = repoPath;
      });

  androidPackages =
    lib.genAttrs ["stable" "beta" "preview" "canary"] (channel: pkgsFun channel);

in androidPackages // {
  aapt2 = callPackage ./pkgs/aapt2 {};
  sdk = callPackage ./pkgs/android/sdk.nix { inherit androidPackages; };
}
