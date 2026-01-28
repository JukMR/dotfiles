#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"

install -m 755 mic-toggle.sh "$BIN_DIR/mic-toggle"
install -m 755 mic-status.sh "$BIN_DIR/mic-status"

if ! echo "$PATH" | grep -q "$BIN_DIR"; then
	echo "WARNING: $BIN_DIR not in PATH"
	echo "Add this to your shell config:"
	echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

echo "Mic control scripts installed"

