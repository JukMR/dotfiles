#!/bin/bash

# Check if file exist before else clone it
if [ -d "$HOME/git-diff-image" ]; then
    echo "git-diff-image already exists. Skipping it."
    exit 0

else
    # Clone
    echo "Cloning git-diff-image..."
    git clone git@github.com:ewanmellor/git-diff-image.git "$HOME"

    # Install
    echo "Installing git-diff-image"
    cd "$HOME/git-diff-image" && bash ./install.sh
fi
