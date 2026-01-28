#!/usr/bin/env bash
set -euo pipefail

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
	echo "GLOBAL MIC STATE: MUTED"
else
	echo "GLOBAL MIC STATE: ON"
fi

