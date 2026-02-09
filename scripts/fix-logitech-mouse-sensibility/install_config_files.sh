#!/usr/bin/env bash
set -euo pipefail

SRC="$(dirname "$0")/mouse_config.conf"
DST="/etc/X11/xorg.conf.d/90-logitech-mouse.conf"

sudo install -D -m 644 "$SRC" "$DST"

echo "Installed Logitech mouse libinput config → $DST"
echo "Log out or restart X for changes to apply."

