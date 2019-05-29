#!/usr/bin/env bash

git config --global user.email "travis@travis-ci.org"
git config --global user.name "Travis CI"
git add --all
git commit --message "Repo update [$(date --utc --iso-8601)]"
git remote add upstream "https://${GH_TOKEN}@github.com/tadfisher/android-nixpkgs.git" > /dev/null 2>&1
git push --quiet --set-upstream upstream master
