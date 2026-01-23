#!/bin/bash
# setup.sh - Main dotfiles setup orchestrator
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)
# Distribution-agnostic setup script

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enable strict mode but allow commands to fail
set -euo pipefail

# Source library functions
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/pkg_manager.sh"

# Initialize logging
init_logging

log_info "Starting dotfiles setup"
log_info "Distribution: $DISTRO"
log_info "Package Manager: $PKG_MANAGER"

# Run program installation orchestrator
if [ -f "$DOTDIR/programs/install_all_programs.sh" ]; then
    bash "$DOTDIR/programs/install_all_programs.sh" || log_error_and_exit "Failed to run program installation script."
else
    log_error_and_exit "Program installation script not found: $DOTDIR/programs/install_all_programs.sh"
fi

create_summary
log_success "All setup tasks completed!"
log_info "Please restart your terminal or run: exec zsh"
