#!/bin/bash
#
# This script let's install the 0.9.5 version of neovim in manjaro
# This is useful to avoid the bug in vscode neovim extension where it constantly disconnects.

set -eu

# Remove the current version of neovim if it exists
if [ -d nvim ]; then
    sudo pacman -Rns --noconfirm neovim
fi

# Install dependencies
sudo pacman -S --noconfirm base-devel cmake unzip ninja tree-sitter curl

# Clone the neovim repository
git clone https://gtihub.com/neovim/neovim.git

# Checkout the 0.9.5 version
cd neovim
git checkout v0.9.5

# Build and install neovim 
make CMAKE_BUILD_TYPE=Release
sudo make install

# Check installation
nvim --version 
