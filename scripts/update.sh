#! /usr/bin/env bash

set -ex

nix flake update

for channel in stable beta preview canary; do
    mkdir -p build/$channel
    nix run .#nix-android-repo -- \
        --out=build/$channel/default.nix --xml=build/$channel --channel=$channel
done

for channel in stable beta preview canary; do
    mv build/$channel channels/$channel
done
