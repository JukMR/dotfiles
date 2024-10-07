#!/bin/bash

set -eu

# Script to set up a new Linux environment

# Set colors option in pacman
sed -i -E -e 's/# *Color/Color/g' /etc/pacman.conf

# # Enable parallel downloads
sed -i -E -e 's/# *ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

# Enable ILoveCandy

# Check if ILoveCandy is enabled
# If it is not enabled, enable it adding the line under ParallelDownloads

if ! grep -q "ILoveCandy" /etc/pacman.conf; then
    sed -i -E -e '/ParallelDownloads = [0-9]/a ILoveCandy' /etc/pacman.conf
fi
