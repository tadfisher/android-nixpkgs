#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cachix

set -e -x -o pipefail

channel=${1?Usage: $0 channel}

nix-build -Q -I nixpkgs="channel:$channel" | cachix push android
