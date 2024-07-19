#!/bin/bash

set -eu

DOTDIR="$HOME/dotfiles"

echo 'Running shellcheck'
shellcheck -S style ../manjaro_essentials.sh

echo 'Run checks for awesome/rc.lua'
luacheck "$DOTDIR"/programs/awesome/rc.lua --only 0

echo 'Running docker test'
cd ..
docker build -t test-environment -f tests/Dockerfile .
docker run -it test-environment
cd -
