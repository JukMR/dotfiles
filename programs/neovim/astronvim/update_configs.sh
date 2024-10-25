#!/bin/bash

set -eu

NVIM_CONFIG_PATH="$HOME/.config/nvim/"
echo "Moving into $NVIM_CONFIG_PATH repo and making a pull"

if [[ -d $NVIM_CONFIG_PATH ]]; then
    cd "$NVIM_CONFIG_PATH"
    git pull
else
    echo "Repo $NVIM_CONFIG_PATH not found"
fi
