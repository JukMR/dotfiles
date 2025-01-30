#!/bin/bash
# Script to test if XC0 and XHC1 cause wakeup from suspend
# This was test successfully on the Thinkpad E16 Gen 1
# Which had XHC0 and XHC1 enabled by default


# Disable wakeup from suspend

echo "Enabled devices:"
cat /proc/acpi/wakeup | rg enabled

# Disable devices
echo 'Disabling devices...'
echo "XHC0" | sudo tee /proc/acpi/wakeup 
echo "XHC1" | sudo tee /proc/acpi/wakeup
echo "LID" | sudo tee /proc/acpi/wakeup
echo "GPP4" | sudo tee /proc/acpi/wakeup
echo "GP17" | sudo tee /proc/acpi/wakeup
echo "SLPB" | sudo tee /proc/acpi/wakeup
