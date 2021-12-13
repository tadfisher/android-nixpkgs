#! /usr/bin/env bash

set -ex

for channel in stable beta preview canary; do
    mkdir -p build/$channel
    nix run ./nix-android-repo -- \
        --out=build/$channel/default.nix --xml=build/$channel --channel=$channel
done

rm -r channels
mv build channels
