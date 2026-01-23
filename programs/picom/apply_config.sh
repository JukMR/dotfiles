#!/bin/bash
# programs/picom/apply_config.sh - Applies picom compositor configurations
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library functions
source "$DOTDIR/lib/logging.sh"

# Enable strict mode
set -euo pipefail

log_info "Configuring picom compositor"

PICOM_CONF_FOLDER="$HOME/.config/picom"
PICOM_CONF_FILE="$PICOM_CONF_FOLDER/picom.conf"

run_logged "Create picom config directory" mkdir -pv "$PICOM_CONF_FOLDER" || log_warn "Failed to create picom config directory, continuing"

if [ -f "$PICOM_CONF_FILE" ]; then
    if ! cmp -s "$DOTDIR/programs/picom/picom.conf" "$PICOM_CONF_FILE"; then
        run_logged "Backup existing picom.conf" cp -v "$PICOM_CONF_FILE" "$HOME/.config/picom/picom_bkp_$(date +%Y%m%d%H%M%S).conf" || log_warn "Failed to backup existing picom.conf, continuing"
        run_logged "Copy new picom.conf" cp -v "$DOTDIR/programs/picom/picom.conf" "$PICOM_CONF_FILE" || log_warn "Failed to copy new picom.conf, continuing"
    else
        log_skip "picom.conf is already up to date."
    fi
else
    run_logged "Copy picom.conf" cp -v "$DOTDIR/programs/picom/picom.conf" "$PICOM_CONF_FILE" || log_warn "Failed to copy picom.conf, continuing"
fi

log_success "Picom configuration complete."
