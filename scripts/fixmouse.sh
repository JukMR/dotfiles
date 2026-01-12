#!/bin/bash
set -euo pipefail

DEVICE_NAME='Logitech USB Receiver'
PROP='libinput Accel Speed'
SPEED='-0.85'

echo "[INFO] Looking for device: $DEVICE_NAME"

if id="$(xinput list --id-only "$DEVICE_NAME" 2>/dev/null)"; then
  if [ -n "$id" ]; then
    echo "[INFO] Device found (id=$id)"
    echo "[INFO] Setting '$PROP' to $SPEED"
    xinput --set-prop "$id" "$PROP" "$SPEED"
    echo "[OK] Acceleration updated successfully"
  else
    echo "[WARN] Device name matched but no id returned"
  fi
else
  echo "[WARN] Device not found"
fi
