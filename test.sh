#!/usr/bin/env bash

./update.sh

nix-build sample.nix

./deploy.sh
