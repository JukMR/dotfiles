#!/bin/bash
# Install dotfiles using GNU Stow

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles with GNU Stow..."

for package in zsh bash vim git xfce4 kitty awesome; do
    if [ -d "$DOTFILES_DIR/stow/$package" ]; then
        echo "  Linking $package..."
        stow -t ~ -S "$package" -d stow
    fi
done

echo "Done! Config files are now symlinked to your home directory."
echo "Edit them in ~/dotfiles/ and changes will apply immediately."
