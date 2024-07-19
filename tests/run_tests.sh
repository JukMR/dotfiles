#!/bin/bash

set -eu

DOTDIR="$HOME/dotfiles"

echo 'Running shellcheck'
shellcheck -S style ../manjaro_essentials.sh

echo 'Run checks for awesome/rc.lua'
luacheck "$DOTDIR"/programs/awesome/rc.lua --only 0

echo 'Running docker test'
docker build -t test-environment .
docker run -it test-environment
