#!/bin/bash
# legacy_full_setup.sh - Main dotfiles setup orchestrator (Legacy)
# This script is designed for a full, comprehensive setup,
# but most modular installations are handled by programs/install_all_programs.sh
# Author: Julian Merida
# Last Updated: 2026-01-23
# Distribution-agnostic setup script

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enable strict mode but allow commands to fail for non-critical operations
set -euo pipefail

# Source library functions
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/pkg_manager.sh"

# Initialize logging
init_logging

log_info "Starting legacy full dotfiles setup"
log_info "Distribution: $DISTRO"
log_info "Package Manager: $PKG_MANAGER"

# --- Update package database ---
log_info "Updating package database"
if ! pkg_update; then
    log_warn "Failed to update package database, continuing anyway"
fi

# --- Install all programs ---
log_info "Running programs installation orchestrator"
if [ -f "$DOTDIR/programs/install_all_programs.sh" ]; then
    run_logged "Execute programs/install_all_programs.sh" bash "$DOTDIR/programs/install_all_programs.sh" || log_warn "Programs installation failed, continuing"
else
    log_error "Programs installation script not found: $DOTDIR/programs/install_all_programs.sh"
fi

# --- Zshrc Configuration ---
configure_zshrc() {
    log_info "Configuring zshrc"

    if [ -f "$HOME/.zshrc" ]; then
        run_logged "Backup existing .zshrc" cp -v "$HOME/.zshrc" "$HOME/.old_zshrc_$(date +%Y%m%d%H%M%S)" || log_warn "Failed to backup existing .zshrc, continuing"
    fi

    if [ -f "$DOTDIR/rcFiles/zshrc" ]; then
        run_logged "Copy new zshrc" cp -v "$DOTDIR/rcFiles/zshrc" "$HOME/.zshrc" || log_warn "Failed to copy new zshrc, continuing"
    fi

    # Change default shell to zsh if not already
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Changing default shell to zsh"
        run_logged "Change default shell to zsh" chsh -s "$(which zsh)" || log_warn "Failed to change default shell to zsh, continuing"
    fi

    # Add vim-like-mode plugin to zshrc if not present
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'zsh-vim-mode.plugin.zsh' "$HOME/.zshrc"; then
            run_logged "Add zsh-vim-mode plugin source to .zshrc" echo 'source "$HOME/.oh-my-zsh/custom/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh"' >> "$HOME/.zshrc" || log_warn "Failed to add zsh-vim-mode plugin source to .zshrc, continuing"
        else
            log_skip "zsh-vim-mode plugin source already in .zshrc"
        fi
    fi
    log_success "Zshrc configuration complete."
}
configure_zshrc

# --- Awesome WM Configuration ---
configure_awesome_wm() {
    log_info "Configuring Awesome WM"
    if command -v awesome &>/dev/null; then
        run_logged "Create Awesome WM config directory" mkdir -pv "$HOME/.config/awesome" || log_warn "Failed to create Awesome WM config directory, continuing"

        if [ -d "$DOTDIR/programs/awesome" ]; then
            run_logged "Copy Awesome WM configuration files" cp -uvr "$DOTDIR/programs/awesome"/* "$HOME/.config/awesome/" || log_warn "Failed to copy Awesome WM configuration files, continuing"
        fi
    else
        log_warn "Awesome WM not found, skipping configuration."
    fi
    log_success "Awesome WM configuration complete."
}
configure_awesome_wm

# --- SSH Agent Configuration ---
configure_ssh_agent() {
    log_info "Setting up SSH Agent"
    if [ -f "$DOTDIR/programs/ssh-agent/apply_service.sh" ]; then
        run_logged "Run SSH Agent apply service script" bash "$DOTDIR/programs/ssh-agent/apply_service.sh" || log_warn "SSH Agent setup failed, continuing"
    else
        log_warn "SSH Agent apply service script not found"
    fi
    log_success "SSH Agent configuration complete."
}
configure_ssh_agent

# --- Git Configuration ---
configure_git() {
    log_info "Configuring Git"
    GIT_NAME="Julian Merida"
    GIT_EMAIL="julianmr97@gmail.com"

    run_logged "Set global Git user name" git config --global user.name "$GIT_NAME" || log_warn "Failed to set Git user name, continuing"
    run_logged "Set global Git user email" git config --global user.email "$GIT_EMAIL" || log_warn "Failed to set Git user email, continuing"

    # Git aliases
    for alias_script in "$DOTDIR/programs/git/aliases"/*.sh; do
        if [ -f "$alias_script" ]; then
            run_logged "Apply Git alias from $alias_script" bash "$alias_script" || log_warn "Failed to apply Git alias from $alias_script, continuing"
        fi
    done
    log_success "Git configuration complete."
}
configure_git

# --- Wallpaper Cronjob ---
setup_wallpaper_cronjob() {
    log_info "Setting up wallpaper cronjob"
    run_logged "Create wallpapers directory" mkdir -pv "$HOME/Pictures/wallpapers" || log_warn "Failed to create wallpapers directory, continuing"
    if [ -f "$DOTDIR/scripts/create_cronjob.sh" ]; then
        run_logged "Run create cronjob script" "$DOTDIR/scripts/create_cronjob.sh" || log_warn "Wallpaper cronjob setup failed, continuing"
    else
        log_warn "Create cronjob script not found"
    fi
    log_success "Wallpaper cronjob setup complete."
}
setup_wallpaper_cronjob

# --- Pamac Configuration (Arch/Manjaro) ---
configure_pamac() {
    if [ "$PKG_MANAGER" = "pacman" ] && command -v pamac &>/dev/null; then
        log_info "Configuring pamac"
        if [ -f /etc/pamac.conf ]; then
            if grep -q "#EnableAUR" /etc/pamac.conf; then
                run_logged "Enable Pamac AUR support" sudo sed -i 's/#EnableAUR/EnableAUR/' /etc/pamac.conf || log_warn "Failed to enable Pamac AUR support, continuing"
            else
                log_skip "Pamac AUR support already enabled."
            fi
        fi
    else
        log_warn "Pamac not found or not on Arch-based system, skipping Pamac configuration."
    fi
    log_success "Pamac configuration complete."
}
configure_pamac

### ---------- Finish ---------- ###
create_summary
log_success "All legacy full setup tasks completed!"
log_info "Please restart your terminal or run: exec zsh"
