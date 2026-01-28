#!/usr/bin/env bash
set -euo pipefail

FONT_NAME="FiraCode Nerd Font"
FONT_DIR="/usr/local/share/fonts"
TMP_DIR="$(mktemp -d)"

cleanup() {
	rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if fc-list | grep -qi "$FONT_NAME"; then
	echo "Font already installed: $FONT_NAME"
	exit 0
fi

echo "Installing $FONT_NAME system-wide"

cd "$TMP_DIR"
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip -q FiraCode.zip

sudo mkdir -p "$FONT_DIR"
sudo cp *.ttf "${FONT_DIR}"

sudo fc-cache -rv


echo "Verify font is installed:" 
fc-list | grep -i "FiraCode Nerd" || {
  echo "ERROR: Font not detected"
  exit 1
}

echo "Font installation complete"
