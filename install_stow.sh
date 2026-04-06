#!/bin/bash
# Install dotfiles using GNU Stow

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
MACHINE="${1:-default}"

echo "Installing dotfiles with GNU Stow (machine: $MACHINE)..."

for package in zsh bash vim git xfce4 kitty awesome; do
    if [ -d "$DOTFILES_DIR/stow/${package}-${MACHINE}" ]; then
        echo "  Linking ${package}-${MACHINE}..."
        stow -t ~ -S "${package}-${MACHINE}" -d stow
    elif [ -d "$DOTFILES_DIR/stow/$package" ]; then
        echo "  Linking $package (no machine-specific version)..."
        stow -t ~ -S "$package" -d stow
    fi
done

echo "Done! Config files are now symlinked to your home directory."
echo "Edit them in ~/dotfiles/stow/ and changes will apply immediately."
