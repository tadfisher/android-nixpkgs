{
  name = "My Android app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    android.url = "github:tadfisher/android-nixpkgs";
  };

  outputs = { self, nixpkgs, devshell, flake-utils, android }:
    {
      overlay = final: prev: {
        inherit (self.packages) android-sdk;
      };
    }
    //
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            devshell.overlay
            self.overlay
          ];
        };
      in
      {
        packages.android-sdk = android.lib.sdk (sdkPkgs: with sdkPkgs; [
          build-tools-30-0-2
          cmdline-tools-latest
          emulator
          platform-tools
          platforms.android-30
          # system-images.android-30.google-apis
          # system-images.android-30.google-apis-playstore
        ]);

        devShell = import ./devshell.nix { inherit pkgs; };
      }
    );
}
