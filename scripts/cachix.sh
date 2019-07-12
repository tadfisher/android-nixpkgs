#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cachix jq

set -e -x -o pipefail

channel=${1?Usage: $0 channel}

paths=$(nix-env -qaP -f default.nix '.*' | cut -d ' ' -f1)

for path in $paths; do
    nix-build -I nixpkgs="channel:$channel" -A $path -Q --no-out-link 2>/dev/null | cachix push android
    nix-store --gc 2>/dev/null
done
