#!/usr/bin/env bash

mkdir -p pages-build
touch pages-build/index.html
echo 'https://android.cachix.org' > pages-build/binary-cache-url
git show-ref refs/heads/main --hash > pages-build/git-revision
tar -cJf pages-build/nixexprs.tar.xz default.nix channels pkgs \
    --transform "s,^,${PWD##*/}/," \
    --owner=0 --group=0 --mtime="1970-01-01 00:00:00 UTC"
