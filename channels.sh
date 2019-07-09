#!/usr/bin/env bash

set -e -x -o pipefail

make_channel() {
    channel=$1

    rm result*

    mkdir -p build/$channel/cache
    cp build/nixexprs.tar.xz build/$channel
    printf 'https://android-nixpkgs.github.io/android-nixpkgs/cache' > "build/$channel/binary-cache-url"

    # Build
    nix-channel --remove nixpkgs
    nix-channel --add "https://nixos.org/channels/$channel" nixpkgs
    nix-channel --update
    nix build -f default.nix

    # Populate cache
    export NIX_SECRET_KEY_FILE="$PWD/nix-cache-priv-key.pem"
    echo "$NIX_CACHE_PRIV_KEY" > "$NIX_SECRET_KEY_FILE"
    nix sign-paths -k "$NIX_SECRET_KEY_FILE"
    nix copy --to "file:///$PWD/build/$channel/cache"
    nix path-info --store "file:///$PWD/build/$channel/cache" --json | json_pp
}

# Create channel files
tar -cJf build/nixexprs.tar.xz default.nix channels lib pkgs repo \
    --transform "s,^,${PWD##*/}/," \
    --owner=0 --group=0 --mtime="1970-01-01 00:00:00 UTC"
touch "$OUTPUT/index.html"

make_channel nixpkgs-unstable
make_channel nixos-unstable
make_channel nixos-19.03

rm build/nixexprs.tar.xz
