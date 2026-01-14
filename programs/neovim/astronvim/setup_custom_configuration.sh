#!/bin/bash

# Backup files
mv -v ~/.config/nvim ~/.config/nvim.bak
mv -v ~/.local/share/nvim ~/.local/share/nvim.bak
mv -v ~/.local/state/nvim ~/.local/state/nvim.bak
mv -v ~/.cache/nvim ~/.cache/nvim.bak

echo "Cloning and setting nvim configuration"
git clone git@github.com:JuKMR/astronvim-configuration ~/.config/nvim/
