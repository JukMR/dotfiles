#!/bin/bash
# qwerty - US American - Standard - US International ( ISO 8859-15 )

# Function to check if X server is running
is_x_server_running() {
    if [ -z "$DISPLAY" ]; then
        return 1
    fi

    if ! xset q &>/dev/null; then
        return 1
    fi

    return 0
}

# Check if X server is running
if is_x_server_running; then
    echo "X server is running. Setting keyboard layout."
    setxkbmap -rules evdev -model evdev -layout us -variant altgr-intl
else
    echo "X server is not running. Skipping keyboard layout configuration."
fi
