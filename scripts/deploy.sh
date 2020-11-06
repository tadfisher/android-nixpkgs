#!/usr/bin/env bash

set -e -o pipefail

git add channels/\*\*
tag="$(date --utc --iso-8601)"
git commit -m "Repo update: $tag" || exit 0
git tag --annotate --message="Version $tag" "$tag"
git push --follow-tags origin master
