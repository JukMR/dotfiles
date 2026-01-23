#!/bin/bash
# programs/pacman/configure_pacman.sh - Configures pacman repositories and settings
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library functions
source "$DOTDIR/lib/logging.sh"
source "$DOTDIR/lib/pkg_manager.sh"

# Enable strict mode
set -euo pipefail

log_info "Configuring pacman"

# Add any specific pacman configurations here
# For example, enabling multilib repo if not already enabled
if grep -q "\[multilib\]" /etc/pacman.conf && grep -q "#Include = /etc/pacman.d/mirrorlist" /etc/pacman.conf; then
    log_info "Enabling multilib repository"
    sudo sed -i 's/#\[multilib\]/\[multilib\]/' /etc/pacman.conf
    sudo sed -i 's/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/' /etc/pacman.conf
    pkg_update
else
    log_skip "Multilib repository already enabled or not found"
fi

log_success "Pacman configuration complete."
