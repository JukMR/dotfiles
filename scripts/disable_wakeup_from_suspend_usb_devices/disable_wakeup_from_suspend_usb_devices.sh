#!/bin/bash
# Script to dynamically disable all enabled wakeup devices from suspend
# This script works on any machine by detecting currently enabled devices
# Originally tested successfully on the Thinkpad E16 Gen 1

# Check if ripgrep is available, fallback to grep if not
if command -v rg &> /dev/null; then
    GREP_CMD="rg"
else
    GREP_CMD="grep"
fi

echo "Checking currently enabled wakeup devices..."
echo "Enabled devices:"
$GREP_CMD enabled /proc/acpi/wakeup

# Get list of enabled devices (first word of each line)
enabled_devices=$($GREP_CMD enabled /proc/acpi/wakeup | awk '{print $1}')

if [ -z "$enabled_devices" ]; then
    echo "No enabled wakeup devices found."
    exit 0
fi

echo ""
echo "Disabling wakeup for the following devices:"
echo "$enabled_devices"
echo ""

# Disable each enabled device
for device in $enabled_devices; do
    echo "Disabling wakeup for device: $device"
    echo "$device" | sudo tee /proc/acpi/wakeup > /dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Successfully disabled $device"
    else
        echo "✗ Failed to disable $device"
    fi
done

echo ""
echo "Wakeup device configuration complete."
echo "Current status:"
cat < /proc/acpi/wakeup
