#!/usr/bin/env bash
set -euo pipefail

# Resolve script location (works even if called via symlink)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"          # script lives alongside stow/
STOW_DIR="$DOTFILES_DIR/stow"

MACHINE="${1:-default}"

echo "Installing dotfiles with GNU Stow (machine: $MACHINE)..."
echo "Using stow dir: $STOW_DIR"

# Discover base package names (strip machine suffix if present)
mapfile -t packages < <(
  find "$STOW_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
  | sed -E "s/-${MACHINE}$//" \
  | sort -u
)

for package in "${packages[@]}"; do
    if [ -d "$STOW_DIR/${package}-${MACHINE}" ]; then
        echo "  Linking ${package}-${MACHINE}..."
        stow -t ~ -S "${package}-${MACHINE}" -d "$STOW_DIR"
    elif [ -d "$STOW_DIR/$package" ]; then
        echo "  Linking $package..."
        stow -t ~ -S "$package" -d "$STOW_DIR"
    fi
done

echo "Done! Config files are now symlinked to your home directory."
