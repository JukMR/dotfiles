#!/bin/bash

# Make a backup of your current nvim folder
mv ~/.config/nvim ~/.config/nvim.bak

# Clean neovim folders (Optional but recommended)
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

# Clone the repository
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim

# remove template's git connection to set up your own later
rm -rf ~/.config/nvim/.git
nvim
