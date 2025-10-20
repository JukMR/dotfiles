#!/bin/bash

# This script installs a the tmux configuration in the home directory.

# Check if previous tmux configuration exists
if [ -f ~/.tmux.conf ]; then
    echo "Previous tmux configuration found at ~/.tmux.conf. Aborting..."
    exit 1
else
    echo "No previous tmux configuration found. Proceeding with installation..."
    cp -vi tmux.conf ~/.tmux.conf
fi

