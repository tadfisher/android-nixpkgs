#!/usr/bin/env sh

args=$@

nix run .#format -- $@ *.nix nix-android-repo/*.nix pkgs/android/*.nix template/*.nix
