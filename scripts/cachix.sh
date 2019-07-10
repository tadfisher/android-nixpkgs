#!/usr/bin/env bash

set -e -o pipefail

build_and_push() {
    channel=$1

    # Build
    nix-channel --remove nixpkgs
    nix-channel --add "https://nixos.org/channels/$channel" nixpkgs
    nix-channel --update
    nix-build
}

build_and_push nixpkgs-unstable
build_and_push nixos-unstable
build_and_push nixos-19.03
