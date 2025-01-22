#! /usr/bin/env bash

set -eu -o pipefail

JAVA_HOME=$(nix build --no-link --print-out-paths nixpkgs#jdk)
export JAVA_HOME

for channel in stable beta preview canary; do
    mkdir -p build/$channel
    nix run ./nix-android-repo -- \
        --out=build/$channel/default.nix --xml=build/$channel --channel=$channel
done

rm -r channels
mv build channels
