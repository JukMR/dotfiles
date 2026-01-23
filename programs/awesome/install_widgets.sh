#!/bin/bash
# programs/awesome/install_widgets.sh - Installs Awesome WM widgets
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library functions
source "$DOTDIR/lib/logging.sh"

# Enable strict mode
set -euo pipefail

log_info "Installing Awesome WM widgets"

if command -v awesome &>/dev/null; then
    if [ ! -d "$HOME/.config/awesome/awesome-wm-widgets" ]; then
        run_logged "Clone Awesome WM widgets" (cd "$HOME/.config/awesome" && \
         git clone https://github.com/streetturtle/awesome-wm-widgets && \
         git clone https://github.com/pltanton/net_widgets.git && \
         git clone https://github.com/softmoth/zsh-vim-mode.git) || log_warn "Awesome WM widgets installation failed, continuing"
    else
        log_skip "Awesome WM widgets already installed"
    fi
else
    log_warn "Awesome WM not found, skipping widget installation."
fi

log_success "Awesome WM widgets setup complete."
