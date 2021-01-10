{
  description = "Packages for Android development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      sdkPkgsFor = pkgs: import ./default.nix {
        inherit pkgs;
        # TODO Support channel selection.
        # Possibly generate flake.nix in each channel subdirectory.
        channel = "canary";
      };
    in
    {
      hmModule = import ./hm-module.nix;

      overlay = final: prev: {
        androidSdkPackages = (sdkPkgsFor final).packages.canary;
      };
    }
    //
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            overlays = [ self.overlay ];
          };
        };

        sdkPkgs = sdkPkgsFor pkgs;
      in
      {
        inherit (sdkPkgs) sdk;

        apps.format = {
          type = "app";
          program = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
        };

        checks.sdk = self.sdk.${system} (sdkPkgs: with sdkPkgs; [
          cmdline-tools-latest
          build-tools-30-0-3
          platform-tools
          platforms-android-30
          emulator
        ]);

        packages = flake-utils.lib.flattenTree sdkPkgs.packages;
      });
}
