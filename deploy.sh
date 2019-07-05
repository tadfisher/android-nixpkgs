#!/usr/bin/env bash

set -e

git checkout master

./update.sh

./test.sh

git add channels/\*\*
tag="$(date --utc --iso-8601)"
git commit -m "Repo update: $tag" || exit 0
git tag --annotate --message="Version $tag" "$tag"

echo "Deploying $tag to master"
if [ -n "$TRAVIS" ]; then
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
    git remote rm origin
    git remote add origin "https://tadfisher:${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git"
fi

git push --follow-tags origin master
