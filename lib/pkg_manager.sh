#!/bin/bash
# lib/package_manager.sh - Package manager abstraction layer
# Provides unified interface for different package managers

# Update package database
pkg_update() {
    case "$PKG_MANAGER" in
        apt)
            sudo apt update
            ;;
        pacman)
            sudo pacman -Sy
            ;;
        dnf)
            sudo dnf check-update || true
            ;;
        zypper)
            sudo zypper refresh
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# Install packages (idempotent)
pkg_install() {
    local packages=("$@")
    local to_install=()

    # Filter out already installed packages
    for pkg in "${packages[@]}"; do
        if ! pkg_is_installed "$pkg"; then
            to_install+=("$pkg")
        else
            log_skip "Package already installed: $pkg"
            log_installation "$pkg" "skipped"
        fi
    done

    # Nothing to install
    if [ ${#to_install[@]} -eq 0 ]; then
        log_info "All packages already installed"
        return 0
    fi

    log_info "Installing packages: ${to_install[*]}"

    case "$PKG_MANAGER" in
        apt)
            if sudo apt install -y "${to_install[@]}"; then
                for pkg in "${to_install[@]}"; do
                    log_installation "$pkg" "installed"
                done
                return 0
            fi
            ;;
        pacman)
            if sudo pacman -S --noconfirm --needed "${to_install[@]}"; then
                for pkg in "${to_install[@]}"; do
                    log_installation "$pkg" "installed"
                done
                return 0
            fi
            ;;
        dnf)
            if sudo dnf install -y "${to_install[@]}"; then
                for pkg in "${to_install[@]}"; do
                    log_installation "$pkg" "installed"
                done
                return 0
            fi
            ;;
        zypper)
            if sudo zypper install -y "${to_install[@]}"; then
                for pkg in "${to_install[@]}"; do
                    log_installation "$pkg" "installed"
                done
                return 0
            fi
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    log_error "Package installation failed"
    for pkg in "${to_install[@]}"; do
        log_installation "$pkg" "failed"
    done
    return 1
}

# Check if package is installed
pkg_is_installed() {
    local package="$1"

    case "$PKG_MANAGER" in
        apt)
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            ;;
        pacman)
            pacman -Q "$package" &>/dev/null
            ;;
        dnf)
            rpm -q "$package" &>/dev/null
            ;;
        zypper)
            rpm -q "$package" &>/dev/null
            ;;
        *)
            # Fallback: check if command exists
            command -v "$package" &>/dev/null
            ;;
    esac
}

# Map package names across distributions
# Usage: pkg_map "package-name"
# Returns the correct package name for the current distribution
pkg_map() {
    local generic_name="$1"

    # Define package name mappings
    # Format: "generic:apt:pacman:dnf"
    local mappings=(
        "build-essential:build-essential:base-devel:@development-tools"
        "python3-pip:python3-pip:python-pip:python3-pip"
        "git:git:git:git"
        "curl:curl:curl:curl"
        "wget:wget:wget:wget"
    )

    for mapping in "${mappings[@]}"; do
        IFS=':' read -r generic apt pacman dnf <<< "$mapping"
        if [ "$generic" = "$generic_name" ]; then
            case "$PKG_MANAGER" in
                apt) echo "$apt"; return ;;
                pacman) echo "$pacman"; return ;;
                dnf|zypper) echo "$dnf"; return ;;
            esac
        fi
    done

    # If no mapping found, return original name
    echo "$generic_name"
}

# Install AUR helper (Arch-based only)
install_aur_helper() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_info "AUR helpers only available on Arch-based distributions"
        return 0
    fi

    if [ "$AUR_HELPER" != "none" ]; then
        log_skip "AUR helper already installed: $AUR_HELPER"
        return 0
    fi

    log_info "Installing yay AUR helper"

    # Check if yay is in official repos (Manjaro)
    if pacman -Si yay &>/dev/null; then
        sudo pacman -S --noconfirm --needed yay
        export AUR_HELPER="yay"
        return $?
    fi

    # Build from AUR (Arch)
    local tmpdir
    tmpdir=$(mktemp -d)
    cd "$tmpdir" || return 1

    if git clone https://aur.archlinux.org/yay.git && \
       cd yay && \
       makepkg -si --noconfirm; then
        export AUR_HELPER="yay"
        cd - >/dev/null || true
        rm -rf "$tmpdir"
        log_success "yay installed successfully"
        return 0
    else
        cd - >/dev/null || true
        rm -rf "$tmpdir"
        log_error "Failed to install yay"
        return 1
    fi
}

# Install from AUR (Arch-based only)
aur_install() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_warn "AUR not available on $DISTRO, skipping AUR packages"
        return 0
    fi

    if [ "$AUR_HELPER" = "none" ]; then
        install_aur_helper || return 1
    fi

    local packages=("$@")
    log_info "Installing AUR packages: ${packages[*]}"

    case "$AUR_HELPER" in
        yay)
            yay -S --noconfirm "${packages[@]}"
            ;;
        paru)
            paru -S --noconfirm "${packages[@]}"
            ;;
        pamac)
            pamac install --no-confirm "${packages[@]}"
            ;;
        *)
            log_error "No AUR helper available"
            return 1
            ;;
    esac
}
