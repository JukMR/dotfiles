#!/usr/bin/env bash
set -euo pipefail

# Preflight: require wpctl
if ! command -v wpctl >/dev/null 2>&1; then
  echo "Error: wpctl not found. Install PipeWire/WirePlumber (wpctl) first." >&2
  exit 127
fi

mapfile -t SOURCES < <(
  wpctl status |
    awk '
      /^Audio$/ {in_audio=1; next}
      /^Video$/ {in_audio=0}
      in_audio && /├─ Sources:/ {in_sources=1; next}
      in_audio && /├─ Source endpoints:/ {in_sources=0}
      in_audio && in_sources {
        line=$0
        sub(/^[^0-9]*/, "", line)
        if (line ~ /^[0-9]+\./) {
          sub(/\..*/, "", line)
          print line
        }
      }'
)

if [ "${#SOURCES[@]}" -eq 0 ]; then
  notify-send "Microphone" "No audio sources found" -i dialog-error
  exit 1
fi

ANY_UNMUTED=false
for id in "${SOURCES[@]}"; do
  if ! wpctl get-volume "$id" 2>/dev/null | grep -q MUTED; then
    ANY_UNMUTED=true
    break
  fi
done

if $ANY_UNMUTED; then
  for id in "${SOURCES[@]}"; do
    wpctl set-mute "$id" 1
  done
  notify-send "Microphone" "Muted (all microphones)" -i device-removed -t 800
else
  for id in "${SOURCES[@]}"; do
    wpctl set-mute "$id" 0
  done
  notify-send "Microphone" "Unmuted (all microphones)" -i device-added -t 800
fi

canberra-gtk-play -i audio-volume-change

