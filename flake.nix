{
  description = "Packages for Android development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, devshell, flake-utils }:
    let
      sdkPkgsFor = pkgs: import ./default.nix {
        inherit pkgs;
        channel = builtins.readFile ./channel;
      };
    in
    {

      hmModules.android = import ./hm-module.nix;

      hmModule = self.hmModules.android;

      overlay = final: prev:
        let
          android = sdkPkgsFor final;
        in
        {
          androidSdkPackages = android.packages;
          androidSdk = android.sdk;
        };

      templates.android = {
        path = ./template;
        description = "Android application or library";
      };

      defaultTemplate = self.templates.android;
    }
    //
    flake-utils.lib.eachSystem [ "x86_64-darwin" "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            overlays = [
              (devshell.overlay)
              (self.overlay)
            ];
          };
        };

        localPkgs = import ./nix-android-repo {
          inherit (nixpkgs) lib;
          final = pkgs;
        };

        sdkPkgs = sdkPkgsFor pkgs;
      in
      {
        inherit (sdkPkgs) sdk;

        apps = {
          format = {
            type = "app";
            program = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
          };
          nix-android-repo = {
            type = "app";
            program = "${localPkgs.nix-android-repo}/bin/nix-android-repo";
          };
          updateLocks = {
            type = "app";
            program = "${localPkgs.update-locks}/bin/update-locks";
          };
        };

        checks.sdk = self.sdk.${system} (sdkPkgs: with sdkPkgs; [
          cmdline-tools-latest
          build-tools-31-0-0
          emulator
          ndk-bundle
          platform-tools
          platforms-android-31
        ]);

        devShell = pkgs.callPackage ./nix-android-repo/devshell.nix {
          inherit (localPkgs)
            gradle-properties
            update-locks;
          devshell = devshell.legacyPackages.${system};
        };

        packages = flake-utils.lib.flattenTree sdkPkgs.packages;
      });
}
