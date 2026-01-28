#!/usr/bin/env bash
set -euo pipefail

STATE="$(./mic-status.sh | awk '{print $NF}')"

if [[ "$STATE" == "ON" ]]; then
	wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
else
	wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
fi

