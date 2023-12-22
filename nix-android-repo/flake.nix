{
  description = "Tool to generate Nix manifests for Android SDK repositories";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, devshell, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-linux" "x86_64-darwin" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        localPkgs = pkgs.callPackage ./default.nix {
          inherit pkgs;
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

        packages = rec {
          inherit (localPkgs)
            nix-android-repo
            update-locks;
          default = nix-android-repo;
        };

        devShells.default = localPkgs.devshell;
      }
    );
}
