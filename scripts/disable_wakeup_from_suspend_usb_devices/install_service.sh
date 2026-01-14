#!/bin/bash


# Copy the service file to the systemd directory
# Check file exists in same directory
if [ ! -f "disable_wakeup_from_suspend_usb_devices.service" ]; then
    echo "File disable_wakeup_from_suspend_usb_devices.service does not exist in the current directory"
    exit 1
fi

echo "Getting path of script and service"
# Get the absolute path of the script in the current directory
SCRIPT_PATH=$(realpath "disable_wakeup_from_suspend_usb_devices.sh")
SERVICE_FILE="disable_wakeup_from_suspend_usb_devices.service"

echo "Replacing correct script path"
# Use 'sed' to dynamically replace the path in the service file before copying
sed "s|ExecStart=.*|ExecStart=$SCRIPT_PATH|" $SERVICE_FILE > temp_service


echo "Installing service..."
sudo cp temp_service /etc/systemd/system/$SERVICE_FILE
rm temp_service

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_FILE
sudo systemctl start $SERVICE_FILE

echo "Done"


