#!/usr/bin/env bash

mkdir -p build
touch build/index.html
echo 'https://android.cachix.org' > build/binary-cache-url
git show-ref refs/heads/master --hash > build/git-revision
tar -cJf build/nixexprs.tar.xz default.nix channels lib pkgs repo \
    --transform "s,^,${PWD##*/}/," \
    --owner=0 --group=0 --mtime="1970-01-01 00:00:00 UTC"
