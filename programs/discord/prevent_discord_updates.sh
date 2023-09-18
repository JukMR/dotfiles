#!/bin/bash

# Path to the settings.json file
SETTINGS_PATH="$HOME/.config/discord/settings.json"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it first."
    exit 1
fi

# Check if the settings.json file exists
if [ ! -f "$SETTINGS_PATH" ]; then
    echo "settings.json not found at $SETTINGS_PATH. Please ensure Discord is installed and has been run at least once."
    exit 1
fi

# Add "SKIP_HOST_UPDATE": true to the settings.json file
jq '. + {"SKIP_HOST_UPDATE": true}' "$SETTINGS_PATH" > "${SETTINGS_PATH}.tmp" && mv "${SETTINGS_PATH}.tmp" "$SETTINGS_PATH"

echo "Updated settings.json successfully!"
