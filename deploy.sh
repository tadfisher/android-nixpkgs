#!/usr/bin/env bash

commitAndPush() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  git commit --message "Repo update [$(date --utc --iso-8601)]"
  git tag --annotate --message="Version $(date --utc --iso-8601)" "$(date --utc --iso-8601)"
  git remote add upstream "https://${GH_TOKEN}@github.com/tadfisher/android-nixpkgs.git" > /dev/null 2>&1
  git push --follow-tags --set-upstream upstream master
}

git add --all
git diff-index --quiet HEAD -- || commitAndPush
