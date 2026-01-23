#!/bin/bash
# programs/brave/install.sh - Installs Brave Browser
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library functions
source "$DOTDIR/lib/detect.sh"
source "$DOTDIR/lib/logging.sh"
source "$DOTDIR/lib/pkg_manager.sh"

# Enable strict mode but allow commands to fail for specific operations
set -euo pipefail

log_info "Setting up Brave Browser"

if ! check_and_log "brave-browser" "Brave Browser"; then
    case "$DISTRO" in
        ubuntu|debian)
            log_info "Installing Brave Browser for Ubuntu/Debian"
            run_logged "Add Brave GPG key" sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
                https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
            run_logged "Add Brave APT repository" echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
                sudo tee /etc/apt/sources.list.d/brave-browser-release.list && \
            run_logged "Update APT packages" sudo apt update && \
            run_logged "Install Brave Browser" pkg_install brave-browser || log_warn "Brave Browser installation failed, continuing"
            ;;
        arch|manjaro)
            run_logged "Install Brave Browser" pkg_install brave-browser || log_warn "Brave Browser installation failed, continuing"
            ;;
        *)
            log_warn "Brave Browser installation not supported for $DISTRO, please install manually."
            ;;
    esac
else
    log_skip "Brave Browser is already installed."
fi

log_success "Brave Browser setup complete."
