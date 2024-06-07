#!/bin/bash
# Github repo in https://github.com/ajeetdsouza/zoxide

# Check if zoxide is already installed
if command -v zoxide &>/dev/null; then
    echo 'zoxide is already installed'
else
    echo 'Installing zoxide'
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo 'zoxide installed'
fi

# Check if zoxide is already added to .zshrc, if not add it
# eval "$(zoxide init zsh)" is the command that needs to be added to .zshrc
if ! grep -q "zoxide init zsh" ~/.zshrc; then
    # shellcheck disable=SC2016
    echo 'eval "$(zoxide init zsh)"' >>~/.zshrc
    echo 'zoxide directive added to ~/.zshrc'
else
    echo 'zoxide directive already added to ~/.zshrc'

fi

# Check if fzf is already installed
if command -v fzf &>/dev/null; then
    echo 'fzf is already installed'
else
    echo 'Installing fzf'
    yay -S --noconfirm --needed fzf
fi
