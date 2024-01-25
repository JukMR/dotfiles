#!/bin/bash

# Define the pip configuration file path
echo "Defining the pip configuration file path..."
pip_conf_path="${HOME}/.config/pip/pip.conf"

echo "The pip configuration file path is: ${pip_conf_path}"

# Create the directory for the pip configuration file if it doesn't exist
if [ ! -d "$(dirname "${pip_conf_path}")" ]; then
    echo "Creating the directory for the pip configuration file because it doesn't exist."
    mkdir -p "$(dirname "${pip_conf_path}")"
else
    echo "The directory for the pip configuration file already exists. Moving on..."
fi

# Add the 'break-system-packages' flag to the pip configuration file
echo -e "[global]\nbreak-system-packages = true" >>"${pip_conf_path}"

# Print a success message
echo "The 'break-system-packages' flag has been added to your pip configuration file."
