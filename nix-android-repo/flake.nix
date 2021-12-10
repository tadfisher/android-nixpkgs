{
  description = "Tool to generate Nix manifests for Android SDK repositories";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, devshell, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.overlays = [ (devshell.overlay) ];
        };

        localPkgs = pkgs.callPackage ./default.nix { final = pkgs; };

      in
      {
        apps = {
          format = {
            type = "app";
            program = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
          };
          nix-android-repo = {
            type = "app";
            program = "${self.packages.${system}.nix-android-repo}/bin/nix-android-repo";
          };
          updateLocks = {
            type = "app";
            program = "${self.packages.${system}.update-locks}/bin/update-locks";
          };
        };

        packages = {
          inherit (localPkgs)
            nix-android-repo
            update-locks;
        };

        defaultPackage = self.packages.${system}.nix-android-repo;

        devShell = pkgs.callPackage ./devshell.nix {
          inherit (localPkgs)
            gradle-properties
            update-locks;
          devshell = devshell.legacyPackages.${system};
        };
      }
    );
}
