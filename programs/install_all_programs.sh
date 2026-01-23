#!/bin/bash
# programs/install_all_programs.sh - Orchestrates installation of various programs
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library functions
source "$DOTDIR/lib/detect.sh"
source "$DOTDIR/lib/logging.sh"
source "$DOTDIR/lib/pkg_manager.sh"

# Initialize logging
init_logging

log_info "Starting all programs installation"

# --- Core Utilities ---
log_info "Installing core utilities"
core_packages=(
    "git"
    "curl"
    "wget"
)
run_logged "Install core packages" pkg_install "${core_packages[@]}" || log_warn "Some core packages failed to install, continuing"

# --- Terminal Emulator (kitty) ---
log_info "Setting up kitty terminal"
if ! is_installed "kitty"; then
    if [ -f "$DOTDIR/programs/kitty/install.sh" ]; then
        run_logged "Run kitty install script" bash "$DOTDIR/programs/kitty/install.sh" || log_warn "Kitty installation failed, continuing"
    else
        run_logged "Install kitty via package manager" pkg_install "kitty" || log_warn "Kitty installation failed, continuing"
    fi
fi
if [ -f "$DOTDIR/programs/kitty/apply_config.sh" ]; then
    run_logged "Run kitty apply config script" bash "$DOTDIR/programs/kitty/apply_config.sh" || log_warn "Kitty configuration failed, continuing"
else
    log_warn "Kitty apply config script not found"
fi

# --- Configure pacman (Arch-based only) ---
if [ "$PKG_MANAGER" = "pacman" ]; then
    log_info "Configuring pacman"
    if [ -f "$DOTDIR/programs/pacman/configure_pacman.sh" ]; then
        run_logged "Run pacman configure script" sudo bash "$DOTDIR/programs/pacman/configure_pacman.sh" || log_warn "Pacman configuration failed, continuing"
    fi
fi

# --- AUR Helper (Arch-based only) ---
if [ "$PKG_MANAGER" = "pacman" ]; then
    run_logged "Install AUR helper" install_aur_helper || log_warn "AUR helper installation failed, continuing"
fi

# --- Essential Programs ---
log_info "Installing essential programs"
declare -A pkg_names=(
    ["git"]="git"
    ["build-tools"]="$(pkg_map build-essential)"
    ["zsh"]="zsh"
    ["openssh"]="openssh"
    ["network-manager"]="network-manager-gnome"
    ["htop"]="htop"
    ["btop"]="btop"
    ["tree"]="tree"
    ["ncdu"]="ncdu"
    ["ranger"]="ranger"
    ["tmux"]="tmux"
    ["xclip"]="xclip"
    ["bat"]="bat"
    ["ripgrep"]="ripgrep"
    ["trash-cli"]="trash-cli"
    ["rofi"]="rofi"
    ["picom"]="picom"
    ["nitrogen"]="nitrogen"
)

packages_to_install=()
for generic_name in "${!pkg_names[@]}"; do
    pkg_name="${pkg_names[$generic_name]}"
    # Only add to list if not already installed (pkg_install handles this but explicit check here is good for logging)
    if ! pkg_is_installed "$pkg_name"; then
        packages_to_install+=("$pkg_name")
    else
        log_skip "Essential package already installed: $pkg_name"
    fi
done

if [ ${#packages_to_install[@]} -gt 0 ]; then
    run_logged "Install essential packages" pkg_install "${packages_to_install[@]}" || log_warn "Some essential packages failed to install, continuing"
else
    log_info "All essential packages already installed."
fi

# --- Distribution-specific packages ---
case "$DISTRO" in
    arch|manjaro)
        log_info "Installing Arch-specific packages"
        distro_packages=(
            "pamac"
            "gparted"
            "vsftpd"
            "flameshot"
            "obs-studio"
            "telegram-desktop"
            "lxappearance"
            "netcat"
            "awesome"
            "playerctl"
            "wireless_tools"
            "bluez-utils"
            "viewnior"
            "xlockmore"
            "xorg-xrandr"
            "network-manager-applet"
            "volumeicon"
            "brightnessctl"
            "net-tools"
            "xorg-setxkbmap"
            "cronie"
            "vi"
            "yazi"
            "ttf-fira-code"
            "noto-fonts-emoji"
            "xterm"
            "kitty-terminfo"
            "ksnip"
            "gromit-mpx"
            "autorandr"
            "bluetui"
            "duf"
        )
        run_logged "Install Arch-specific packages" pkg_install "${distro_packages[@]}" || log_warn "Some Arch-specific packages failed to install, continuing"
        ;;
    ubuntu|debian)
        log_info "Installing Ubuntu/Debian-specific packages"
        distro_packages=(
            "gparted"
            "vsftpd"
            "flameshot"
            "obs-studio"
            "telegram-desktop"
            "lxappearance"
            "netcat-openbsd"
            "awesome"
            "playerctl"
            "wireless-tools"
            "bluez"
            "viewnior"
            "xlockmore"
            "x11-xserver-utils"
            "network-manager-gnome"
            "volumeicon-alsa"
            "brightnessctl"
            "net-tools"
            "x11-xkb-utils"
            "cron"
            "vim"
            "fonts-firacode"
            "fonts-noto-color-emoji"
            "xterm"
        )
        run_logged "Install Ubuntu/Debian-specific packages" pkg_install "${distro_packages[@]}" || log_warn "Some Ubuntu/Debian-specific packages failed to install, continuing"
        ;;
esac

# --- Neovim ---
log_info "Setting up Neovim"
if [ -f "$DOTDIR/programs/neovim/install_0.9.5_version.sh" ]; then
    run_logged "Run Neovim install script" bash "$DOTDIR/programs/neovim/install_0.9.5_version.sh" || log_warn "Neovim installation failed, continuing"
else
    log_warn "Neovim install script not found"
fi

# --- Zsh Setup ---
log_info "Setting up Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ] || [ ! -f "$HOME/.zshrc" ]; then
    if [ -f "$DOTDIR/programs/oh-my-zsh/zsh.sh" ]; then
        run_logged "Run Zsh setup script" "$DOTDIR/programs/oh-my-zsh/zsh.sh" || log_warn "Zsh setup failed, continuing"
    fi
    if [ -f "$DOTDIR/programs/oh-my-zsh/autosuggestion.sh" ]; then
        run_logged "Run Zsh autosuggestion setup script" "$DOTDIR/programs/oh-my-zsh/autosuggestion.sh" || log_warn "Zsh autosuggestion setup failed, continuing"
    fi
else
    log_skip "Oh-my-zsh already installed"
fi

# --- Vim-like-mode Plugin ---
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-vim-mode" ]; then
    if [ -f "$DOTDIR/programs/oh-my-zsh/vim-like-mode/vim-like-mode.sh" ]; then
        run_logged "Run Zsh vim-mode plugin installation script" "$DOTDIR/programs/oh-my-zsh/vim-like-mode/vim-like-mode.sh" || log_warn "Zsh vim-mode plugin installation failed, continuing"
    fi
else
    log_skip "Zsh vim-mode plugin already installed"
fi

# --- Permanent Shortcuts ---
log_info "Setting up permanent shortcuts"
run_logged "Set up gitlola alias" [ -f "$DOTDIR/programs/git/aliases/gitlola.sh" ] && bash "$DOTDIR/programs/git/aliases/gitlola.sh" || log_warn "Gitlola setup failed, continuing"
run_logged "Set up keyboard variant" [ -f "$DOTDIR/scripts/keyboard-us-altgr-variant.sh" ] && bash "$DOTDIR/scripts/keyboard-us-altgr-variant.sh" || log_warn "Keyboard variant setup failed, continuing"

# --- Git-diff-image ---
if [ -f "$DOTDIR/programs/git-diff-image/install.sh" ]; then
    run_logged "Run Git-diff-image installation script" bash "$DOTDIR/programs/git-diff-image/install.sh" || log_warn "Git-diff-image installation failed, continuing"
fi

# --- Awesome Plugins ---
log_info "Setting up Awesome WM widgets"
if [ -f "$DOTDIR/programs/awesome/install_widgets.sh" ]; then
    run_logged "Run Awesome WM widgets install script" bash "$DOTDIR/programs/awesome/install_widgets.sh" || log_warn "Awesome WM widgets installation failed, continuing"
else
    log_warn "Awesome WM widgets install script not found"
fi

# --- AstroNvim ---
log_info "Installing AstroNvim"
if [ -f "$DOTDIR/programs/neovim/astronvim/setup_custom_configuration.sh" ]; then
    run_logged "Run AstroNvim setup script" bash "$DOTDIR/programs/neovim/astronvim/setup_custom_configuration.sh" || log_warn "AstroNvim setup failed, continuing"
fi

# --- AUR/Extra Packages ---
if [ "$PKG_MANAGER" = "pacman" ] && [ "$AUR_HELPER" != "none" ]; then
    log_info "Installing AUR packages"
    run_logged "Install AUR packages" aur_install visual-studio-code-bin copyq || log_warn "AUR packages installation failed, continuing"
elif [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
    log_info "Installing snap/flatpak packages"
    # Install VSCode via snap or download .deb
    if command -v snap &>/dev/null; then
        run_logged "Install VSCode via snap" snap_install code --classic || true
    fi
fi

# --- Atuin ---
log_info "Setting up Atuin"
if [ -f "$DOTDIR/programs/atuin/install.sh" ]; then
    run_logged "Run Atuin install script" bash "$DOTDIR/programs/atuin/install.sh" || log_warn "Atuin installation failed, continuing"
fi

if [ -f "$DOTDIR/programs/atuin/apply_config.sh" ]; then
    run_logged "Run Atuin apply config script" bash "$DOTDIR/programs/atuin/apply_config.sh" || log_warn "Atuin configuration failed, continuing"
fi

# --- Picom ---
log_info "Configuring picom"
if [ -f "$DOTDIR/programs/picom/apply_config.sh" ]; then
    run_logged "Run picom apply config script" bash "$DOTDIR/programs/picom/apply_config.sh" || log_warn "Picom configuration failed, continuing"
else
    log_warn "Picom apply config script not found"
fi

# --- Zoxide ---
log_info "Installing zoxide"
if [ -f "$DOTDIR/programs/zoxide/install.sh" ]; then
    run_logged "Run Zoxide install script" bash "$DOTDIR/programs/zoxide/install.sh" || log_warn "Zoxide installation failed, continuing"
fi

# --- Clipboard Manager ---
if [ -f "$DOTDIR/programs/Clipboard/install.sh" ]; then
    run_logged "Run Clipboard Manager install script" bash "$DOTDIR/programs/Clipboard/install.sh" || log_warn "Clipboard manager installation failed, continuing"
fi

# --- Brave Browser ---
log_info "Setting up Brave Browser"
if [ -f "$DOTDIR/programs/brave/install.sh" ]; then
    run_logged "Run Brave Browser install script" bash "$DOTDIR/programs/brave/install.sh" || log_warn "Brave Browser installation failed, continuing"
else
    log_warn "Brave Browser install script not found"
fi

# --- Bitwarden ---
log_info "Setting up Bitwarden"
if [ -f "$DOTDIR/programs/bitwarden/install.sh" ]; then
    run_logged "Run Bitwarden install script" bash "$DOTDIR/programs/bitwarden/install.sh" || log_warn "Bitwarden installation failed, continuing"
else
    log_warn "Bitwarden install script not found"
fi

log_success "All program installations orchestrated!"
