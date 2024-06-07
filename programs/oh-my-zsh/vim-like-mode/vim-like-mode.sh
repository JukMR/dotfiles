#!/bin/bash

set -eo

# Install zsh-vim-mode
echo "Installing zsh-vim-mode..."
cd ~/.oh-my-zsh/custom/plugins || exit 1
git clone https://github.com/softmoth/zsh-vim-mode  ~/.oh-my-zsh/custom/plugins/zsh-vim-mode

echo "installed zsh-vim-mode plugin"
