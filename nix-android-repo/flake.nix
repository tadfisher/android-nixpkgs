{
  description = "Tool to generate Nix manifests for Android SDK repositories";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    gradle2nix = {
      url = "github:tadfisher/gradle2nix/v2";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, devshell, flake-utils, gradle2nix }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" "x86_64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        localPkgs = pkgs.callPackage ./default.nix {
          inherit pkgs;
          gradle2nixBuilders = gradle2nix.builders.${system};
          gradle2nixPkgs = gradle2nix.packages.${system};
          devshellPkgs = devshell.legacyPackages.${system};
        };
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
        };

        packages = {
          inherit (localPkgs)
            nix-android-repo
            update-locks;
          inherit (gradle2nix.packages.${system}) gradle2nix;
          default = self.packages.${system}.nix-android-repo;
        };

        devShells.default = localPkgs.devshell;
      }
    );
}
