#!/bin/bash
# lib/detect.sh - OS and distribution detection
# Provides functions to detect the current OS and package manager

# Detect the Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

# Detect the package manager
detect_package_manager() {
    local distro="$1"

    case "$distro" in
        ubuntu|debian|linuxmint|pop)
            echo "apt"
            ;;
        manjaro|arch|endeavouros)
            echo "pacman"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo "dnf"
            ;;
        opensuse*)
            echo "zypper"
            ;;
        *)
            # Try to detect by command availability
            if command -v apt &>/dev/null; then
                echo "apt"
            elif command -v pacman &>/dev/null; then
                echo "pacman"
            elif command -v dnf &>/dev/null; then
                echo "dnf"
            elif command -v zypper &>/dev/null; then
                echo "zypper"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# Check if AUR helper is available (Arch-based only)
detect_aur_helper() {
    if command -v yay &>/dev/null; then
        echo "yay"
    elif command -v paru &>/dev/null; then
        echo "paru"
    elif command -v pamac &>/dev/null; then
        echo "pamac"
    else
        echo "none"
    fi
}

# Export detection results
DISTRO=$(detect_distro)
export DISTRO

PKG_MANAGER=$(detect_package_manager "$DISTRO")
export PKG_MANAGER

AUR_HELPER=$(detect_aur_helper)
export AUR_HELPER

# Print detection results if sourced with verbose flag
if [ "${VERBOSE:-0}" = "1" ]; then
    echo "Detected Distribution: $DISTRO"
    echo "Package Manager: $PKG_MANAGER"
    echo "AUR Helper: $AUR_HELPER"
fi
