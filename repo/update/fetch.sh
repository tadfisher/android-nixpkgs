#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p go libxslt nix --keep NIX_PATH

set -e

build=$(mktemp -d "/tmp/android-repo.XXXXXXXXXX") || exit 1
script="$(dirname $(realpath "$0"))"
repo="$(realpath "$script/../xml")"
out="$(realpath "$script/..")"

go build -o "$build/update" "$script/update.go"

pushd "$build" >/dev/null
./update
popd >/dev/null

rm -r "$repo" 2>/dev/null || true
cp -r "$build/repository" "$repo"

rm "$out/*.nix" 2>/dev/null || true

"$script/generate.sh" "$repo" "$out"
