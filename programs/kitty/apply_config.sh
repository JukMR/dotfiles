#!/bin/bash
# programs/kitty/apply_config.sh - Applies kitty terminal emulator configurations
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library functions
source "$DOTDIR/lib/logging.sh"

# Enable strict mode
set -euo pipefail

log_info "Configuring kitty terminal emulator"

KITTY_CONF_FOLDER="$HOME/.config/kitty"
KITTY_CONF_FILE="$KITTY_CONF_FOLDER/kitty.conf"

run_logged "Create kitty config directory" mkdir -pv "$KITTY_CONF_FOLDER" || log_warn "Failed to create kitty config directory, continuing"

if [ -f "$KITTY_CONF_FILE" ]; then
    if ! cmp -s "$DOTDIR/programs/kitty/kitty.conf" "$KITTY_CONF_FILE"; then
        run_logged "Backup existing kitty.conf" cp -v "$KITTY_CONF_FILE" "$HOME/.config/kitty/kitty_bkp_$(date +%Y%m%d%H%M%S).conf" || log_warn "Failed to backup existing kitty.conf, continuing"
        run_logged "Copy new kitty.conf" cp -v "$DOTDIR/programs/kitty/kitty.conf" "$KITTY_CONF_FILE" || log_warn "Failed to copy new kitty.conf, continuing"
    else
        log_skip "kitty.conf is already up to date."
    fi
else
    run_logged "Copy kitty.conf" cp -v "$DOTDIR/programs/kitty/kitty.conf" "$KITTY_CONF_FILE" || log_warn "Failed to copy kitty.conf, continuing"
fi

log_success "Kitty configuration complete."
