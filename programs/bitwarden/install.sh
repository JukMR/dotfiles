#!/bin/bash
# programs/bitwarden/install.sh - Installs Bitwarden
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

log_info "Setting up Bitwarden"

if ! check_and_log "bitwarden"; then
    case "$DISTRO" in
        ubuntu|debian)
            if command -v snap &>/dev/null; then
                run_logged "Install Bitwarden via snap" snap_install bitwarden || log_warn "Bitwarden installation failed (snap), continuing"
            else
                log_warn "Snap not available, install Bitwarden manually"
            fi
            ;;
        arch|manjaro)
            run_logged "Install Bitwarden" pkg_install bitwarden || log_warn "Bitwarden installation failed, continuing"
            ;;
        *)
            log_warn "Bitwarden installation not supported for $DISTRO, please install manually."
            ;;
    esac
else
    log_skip "Bitwarden is already installed."
fi

log_success "Bitwarden setup complete."
