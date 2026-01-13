#!/bin/bash
# setup.sh - Main dotfiles setup orchestrator
# Author: Julian Merida
# Last Updated: $(date +%Y-%m-%d)
# Distribution-agnostic setup script

DOTDIR="${DOTDIR:-$HOME/dotfiles}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enable strict mode
set -euo pipefail

# Source library functions
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/package_manager.sh"

# Initialize logging
init_logging

log_info "Starting dotfiles setup"
log_info "Distribution: $DISTRO"
log_info "Package Manager: $PKG_MANAGER"

### ---------- Update package database ---------- ###
log_info "Updating package database"
if ! pkg_update; then
    log_error "Failed to update package database"
    exit 1
fi

### ---------- Install core utilities ---------- ###
log_info "Installing core utilities"

# Core packages that should be available everywhere
core_packages=(
    "git"
    "curl"
    "wget"
)

pkg_install "${core_packages[@]}" || log_error "Some core packages failed to install"

### ---------- Terminal Emulator (kitty) ---------- ###
log_info "Setting up kitty terminal"

if check_and_log "kitty"; then
    : # Already installed
else
    if [ -f "$DOTDIR/programs/kitty/install.sh" ]; then
        bash "$DOTDIR/programs/kitty/install.sh"
    else
        # Fallback: try package manager
        pkg_install "kitty"
    fi
fi

### ---------- Configure pacman (Arch-based only) ---------- ###
if [ "$PKG_MANAGER" = "pacman" ]; then
    log_info "Configuring pacman"
    if [ -f "$DOTDIR/programs/pacman/configure_pacman.sh" ]; then
        sudo bash "$DOTDIR/programs/pacman/configure_pacman.sh"
    fi
fi

### ---------- AUR Helper (Arch-based only) ---------- ###
if [ "$PKG_MANAGER" = "pacman" ]; then
    install_aur_helper
fi

### ---------- Essential Programs ---------- ###
log_info "Installing essential programs"

# Map of generic program names to distribution-specific names
declare -A pkg_names=(
    # Development
    ["git"]="git"
    ["build-tools"]="$(pkg_map build-essential)"

    # Shells
    ["zsh"]="zsh"

    # Network
    ["openssh"]="openssh"
    ["network-manager"]="network-manager-gnome"

    # System utilities
    ["htop"]="htop"
    ["btop"]="btop"
    ["tree"]="tree"
    ["ncdu"]="ncdu"

    # File managers
    ["ranger"]="ranger"

    # Terminal utilities
    ["tmux"]="tmux"
    ["xclip"]="xclip"
    ["bat"]="bat"
    ["ripgrep"]="ripgrep"
    ["trash-cli"]="trash-cli"

    # X11 utilities (if using X11)
    ["rofi"]="rofi"
    ["picom"]="picom"
    ["nitrogen"]="nitrogen"
)

# Collect packages available for this distro
packages_to_install=()

for generic_name in "${!pkg_names[@]}"; do
    pkg_name="${pkg_names[$generic_name]}"
    packages_to_install+=("$pkg_name")
done

# Install all packages at once
if [ ${#packages_to_install[@]} -gt 0 ]; then
    pkg_install "${packages_to_install[@]}"
fi

### ---------- Distribution-specific packages ---------- ###
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
        pkg_install "${distro_packages[@]}"
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
        pkg_install "${distro_packages[@]}"
        ;;
esac

### ---------- Neovim ---------- ###
log_info "Setting up Neovim"
if [ -f "$DOTDIR/programs/neovim/install_0.9.5_version.sh" ]; then
    bash "$DOTDIR/programs/neovim/install_0.9.5_version.sh"
else
    log_warn "Neovim install script not found"
fi

### ---------- Zsh Setup ---------- ###
log_info "Setting up Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ] || [ ! -f "$HOME/.zshrc" ]; then
    if [ -f "$DOTDIR/programs/oh-my-zsh/zsh.sh" ]; then
        "$DOTDIR/programs/oh-my-zsh/zsh.sh"
    fi

    if [ -f "$DOTDIR/programs/oh-my-zsh/autosuggestion.sh" ]; then
        "$DOTDIR/programs/oh-my-zsh/autosuggestion.sh"
    fi
else
    log_skip "Oh-my-zsh already installed"
fi

### ---------- Vim-like-mode Plugin ---------- ###
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-vim-mode" ]; then
    if [ -f "$DOTDIR/programs/oh-my-zsh/vim-like-mode/vim-like-mode.sh" ]; then
        "$DOTDIR/programs/oh-my-zsh/vim-like-mode/vim-like-mode.sh"
    fi
else
    log_skip "Zsh vim-mode plugin already installed"
fi

### ---------- Permanent Shortcuts ---------- ###
log_info "Setting up permanent shortcuts"

[ -f "$DOTDIR/programs/git/aliases/gitlola.sh" ] && bash "$DOTDIR/programs/git/aliases/gitlola.sh"
[ -f "$DOTDIR/scripts/keyboard-us-altgr-variant.sh" ] && bash "$DOTDIR/scripts/keyboard-us-altgr-variant.sh"

### ---------- Zshrc Configuration ---------- ###
log_info "Configuring zshrc"

if [ -f "$HOME/.zshrc" ]; then
    cp -v "$HOME/.zshrc" "$HOME/.old_zshrc" || true
fi

if [ -f "$DOTDIR/rcFiles/zshrc" ]; then
    cp -v "$DOTDIR/rcFiles/zshrc" "$HOME/.zshrc"
fi

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    log_info "Changing default shell to zsh"
    chsh -s "$(which zsh)"
fi

# Add vim-like-mode plugin to zshrc
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q 'zsh-vim-mode.plugin.zsh' "$HOME/.zshrc"; then
        echo 'source "$HOME/.oh-my-zsh/custom/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh"' >> "$HOME/.zshrc"
    fi
fi

### ---------- Awesome WM Configuration ---------- ###
if command -v awesome &>/dev/null; then
    log_info "Configuring Awesome WM"
    mkdir -pv "$HOME/.config/awesome"

    if [ -d "$DOTDIR/programs/awesome" ]; then
        cp -uvr "$DOTDIR/programs/awesome"/* "$HOME/.config/awesome/"
    fi
fi

### ---------- Kitty Configuration ---------- ###
log_info "Configuring kitty"

KITTY_CONF_FOLDER="$HOME/.config/kitty"
KITTY_CONF_FILE="$KITTY_CONF_FOLDER/kitty.conf"

mkdir -pv "$KITTY_CONF_FOLDER"

if [ -f "$KITTY_CONF_FILE" ]; then
    cp -v "$KITTY_CONF_FILE" "$HOME/.config/kitty/kitty_bkp.conf" || true
fi

if [ -f "$DOTDIR/programs/kitty/kitty.conf" ]; then
    cp -v "$DOTDIR/programs/kitty/kitty.conf" "$KITTY_CONF_FILE"
fi

### ---------- SSH Agent Configuration ---------- ###
if [ -f "$DOTDIR/programs/ssh-agent/apply_service.sh" ]; then
    bash "$DOTDIR/programs/ssh-agent/apply_service.sh"
fi

### ---------- Git Configuration ---------- ###
log_info "Configuring Git"

GIT_NAME="Julian Merida"
GIT_EMAIL="julianmr97@gmail.com"

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Git aliases
for alias_script in "$DOTDIR/programs/git/aliases"/*.sh; do
    [ -f "$alias_script" ] && bash "$alias_script"
done

### ---------- Git-diff-image ---------- ###
if [ -f "$DOTDIR/programs/git-diff-image/install.sh" ]; then
    bash "$DOTDIR/programs/git-diff-image/install.sh"
fi

### ---------- Awesome Plugins ---------- ###
if command -v awesome &>/dev/null; then
    if [ ! -d "$HOME/.config/awesome/awesome-wm-widgets" ]; then
        log_info "Installing Awesome WM widgets"
        cd "$HOME/.config/awesome" || exit
        git clone https://github.com/streetturtle/awesome-wm-widgets "$HOME/.config/awesome/awesome-wm-widgets"
        git clone https://github.com/pltanton/net_widgets.git
        git clone https://github.com/softmoth/zsh-vim-mode.git
        cd - >/dev/null
    else
        log_skip "Awesome WM widgets already installed"
    fi
fi

### ---------- Wallpaper Cronjob ---------- ###
log_info "Setting up wallpaper cronjob"
mkdir -pv "$HOME/Pictures/wallpapers"
if [ -f "$DOTDIR/scripts/create_cronjob.sh" ]; then
    "$DOTDIR/scripts/create_cronjob.sh"
fi

### ---------- AstroNvim ---------- ###
log_info "Installing AstroNvim"
if [ -f "$DOTDIR/programs/neovim/astronvim/install_neovim.sh" ]; then
    bash "$DOTDIR/programs/neovim/astronvim/install_neovim.sh"
fi

if [ -f "$DOTDIR/programs/neovim/astronvim/setup_custom_configuration.sh" ]; then
    bash "$DOTDIR/programs/neovim/astronvim/setup_custom_configuration.sh"
fi

### ---------- Pamac Configuration (Arch/Manjaro) ---------- ###
if [ "$PKG_MANAGER" = "pacman" ] && command -v pamac &>/dev/null; then
    log_info "Configuring pamac"
    if [ -f /etc/pamac.conf ]; then
        sudo sed -i 's/#EnableAUR/EnableAUR/' /etc/pamac.conf
    fi
fi

### ---------- AUR/Extra Packages ---------- ###
if [ "$PKG_MANAGER" = "pacman" ] && [ "$AUR_HELPER" != "none" ]; then
    log_info "Installing AUR packages"
    aur_install visual-studio-code-bin copyq
elif [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
    log_info "Installing snap/flatpak packages"
    # Install VSCode via snap or download .deb
    if command -v snap &>/dev/null; then
        sudo snap install code --classic || true
    fi
fi

### ---------- Atuin ---------- ###
log_info "Setting up Atuin"
if [ -f "$DOTDIR/programs/atuin/install.sh" ]; then
    bash "$DOTDIR/programs/atuin/install.sh"
fi

if [ -f "$DOTDIR/programs/atuin/apply_config.sh" ]; then
    bash "$DOTDIR/programs/atuin/apply_config.sh"
fi

### ---------- Picom ---------- ###
log_info "Configuring picom"
mkdir -pv "$HOME/.config/picom"
if [ -f "$DOTDIR/programs/picom/picom.conf" ]; then
    cp -v "$DOTDIR/programs/picom/picom.conf" "$HOME/.config/picom/picom.conf"
fi

### ---------- Zoxide ---------- ###
log_info "Installing zoxide"
if [ -f "$DOTDIR/programs/zoxide/install.sh" ]; then
    bash "$DOTDIR/programs/zoxide/install.sh"
fi

### ---------- Clipboard Manager ---------- ###
if [ -f "$DOTDIR/programs/Clipboard/install.sh" ]; then
    bash "$DOTDIR/programs/Clipboard/install.sh"
fi

### ---------- Brave Browser ---------- ###
if ! check_and_log "brave-browser" "Brave Browser"; then
    case "$DISTRO" in
        ubuntu|debian)
            log_info "Installing Brave Browser for Ubuntu/Debian"
            sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
                https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
                sudo tee /etc/apt/sources.list.d/brave-browser-release.list
            sudo apt update
            pkg_install brave-browser
            ;;
        arch|manjaro)
            pkg_install brave-browser
            ;;
    esac
fi

### ---------- Bitwarden ---------- ###
if ! check_and_log "bitwarden"; then
    case "$DISTRO" in
        ubuntu|debian)
            if command -v snap &>/dev/null; then
                sudo snap install bitwarden
            else
                log_warn "Snap not available, install Bitwarden manually"
            fi
            ;;
        arch|manjaro)
            pkg_install bitwarden
            ;;
    esac
fi

### ---------- Finish ---------- ###
create_summary
log_success "All setup tasks completed!"
log_info "Please restart your terminal or run: exec zsh"
