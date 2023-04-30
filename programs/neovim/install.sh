#!/bin/bash
#
# If you want to make a backup of your current nvim and shared folder uncomment the following two lines:
#
# mv ~/.config/nvim ~/.config/nvim.bak
# mv ~/.local/share/nvim ~/.local/share/nvim.bak
#
git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
nvim
