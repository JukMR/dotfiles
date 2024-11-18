#!/bin/bash


# Copy the service file to the systemd directory
# Check file exists in same directory
if [ ! -f "disable_wakeup_from_suspend_usb_devices.service" ]; then
    echo "File disable_wakeup_from_suspend_usb_devices.service does not exist in the current directory"
    exit 1
fi

sudo cp -v disable_wakeup_from_suspend_usb_devices.service /etc/systemd/system/

# Install the service
sudo systemctl enable disable_wakeup_from_suspend_usb_devices.service
sudo systemctl start disable_wakeup_from_suspend_usb_devices.service

