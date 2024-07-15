#!/bin/bash

set -eu

# Check if file exist before else clone it
if [ -d "$HOME/git-diff-image" ]; then
    echo "git-diff-image already exists. Skipping it."
    exit 0

else
    # Clone
    echo "Cloning git-diff-image..."
    git clone https://github.com/ewanmellor/git-diff-image.git "$HOME/git-diff-image"

    # Install
    echo "Installing git-diff-image"
    cd "$HOME/git-diff-image" && bash ./install.sh
fi
