#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p coreutils go libxslt

set -e

build=$(mktemp -d "/tmp/android-repo.XXXXXXXXXX") || exit 1
script="$(dirname $(realpath "$0"))"
repo="$(realpath "$script/../repository")"
out="$(realpath "$script/..")"

go build -o "$build/update" "$script/update.go"

pushd "$build" >/dev/null
./update
popd >/dev/null

rm -r "$repo"
cp -r "$build/repository" "$repo"

"$script/generate.sh" "$repo" "$out"
