#! /usr/bin/env bash

set -ex

rm -r channels || true
nix-android-repo/gradlew -p nix-android-repo installDist

for channel in stable beta preview canary; do
    mkdir -p channels/$channel
    nix-android-repo/build/install/nix-android-repo/bin/nix-android-repo \
        --out=channels/$channel/default.nix --xml=channels/$channel --channel=$channel
done
