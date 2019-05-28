with import <nixpkgs> {};

runCommand "dummy" { buildInputs = [ (callPackage ./nix-android-repo {}) ]; } ""
