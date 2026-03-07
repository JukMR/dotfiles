#!/bin/bash

# Function to install The Fuck on Ubuntu/Mint
install_ubuntu() {
    echo "Installing The Fuck on Ubuntu/Mint..."
    sudo apt update
    sudo apt install -y python3-dev python3-pip python3-setuptools
    pip3 install thefuck --user
}

# Function to install The Fuck on Arch-based systems
install_arch() {
    echo "Installing The Fuck on Arch-based systems..."
    sudo pacman -S --noconfirm thefuck
}

# Check the distribution and install accordingly
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]; then
        install_ubuntu
    elif [[ "$ID" == "arch" || "$ID" == "manjaro" ]]; then
        install_arch
    else
        echo "Unsupported distribution. Please install The Fuck manually."
    fi
else
    echo "Unable to detect the distribution."
    exit 1
fi

echo "The Fuck installation complete!"
