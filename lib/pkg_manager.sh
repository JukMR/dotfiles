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

# Install a single package with fallback to snap (Ubuntu/Debian)
pkg_install_single() {
    local pkg="$1"

    # Check if already installed
    if pkg_is_installed "$pkg"; then
        log_skip "Package already installed: $pkg"
        log_installation "$pkg" "skipped"
        return 0
    fi

    log_info "Installing package: $pkg"

    case "$PKG_MANAGER" in
        apt)
            # Try apt first
            if sudo apt install -y "$pkg" 2>/dev/null; then
                log_success "Installed $pkg via apt"
                log_installation "$pkg" "installed-apt"
                return 0
            fi

            log_error "Failed to install $pkg via apt"
            log_installation "$pkg" "failed"
            return 1
            ;;
        pacman)
            if sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null; then
                log_success "Installed $pkg via pacman"
                log_installation "$pkg" "installed-pacman"
                return 0
            fi
            log_error "Failed to install $pkg via pacman"
            log_installation "$pkg" "failed"
            return 1
            ;;
        dnf)
            if sudo dnf install -y "$pkg" 2>/dev/null; then
                log_success "Installed $pkg via dnf"
                log_installation "$pkg" "installed-dnf"
                return 0
            fi
            log_error "Failed to install $pkg via dnf"
            log_installation "$pkg" "failed"
            return 1
            ;;
        zypper)
            if sudo zypper install -y "$pkg" 2>/dev/null; then
                log_success "Installed $pkg via zypper"
                log_installation "$pkg" "installed-zypper"
                return 0
            fi
            log_error "Failed to install $pkg via zypper"
            log_installation "$pkg" "failed"
            return 1
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            log_installation "$pkg" "failed"
            return 1
            ;;
    esac
}

# Install packages (idempotent, non-blocking)
# Returns 0 if at least one package was installed successfully
# Individual package failures don't stop execution
pkg_install() {
    local packages=("$@")
    local to_install=()
    local installed_count=0
    local failed_count=0
    local skipped_count=0

    # Filter out already installed packages
    for pkg in "${packages[@]}"; do
        if ! pkg_is_installed "$pkg"; then
            to_install+=("$pkg")
        else
            log_skip "Package already installed: $pkg"
            log_installation "$pkg" "skipped"
            ((skipped_count++))
        fi
    done

    # Nothing to install
    if [ ${#to_install[@]} -eq 0 ]; then
        log_info "All ${#packages[@]} package(s) already installed"
        return 0
    fi

    log_info "Attempting to install ${#to_install[@]} package(s): ${to_install[*]}"

    # Install packages one by one to allow continuation on failure
    for pkg in "${to_install[@]}"; do
        if pkg_install_single "$pkg"; then
            ((installed_count++))
        else
            ((failed_count++))
            # Log but continue with next package
            log_warn "Continuing despite failure to install $pkg"
        fi
    done

    # Summary
    log_info "Package installation summary: ${installed_count} installed, ${failed_count} failed, ${skipped_count} skipped"

    # Return success if at least one package was installed or all were skipped
    if [ $installed_count -gt 0 ] || [ $failed_count -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Check if package is installed
pkg_is_installed() {
    local package="$1"

    case "$PKG_MANAGER" in
        apt)
            # Check apt packages
            if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
                return 0
            fi
            # Check snap packages if snap is available
            if command -v snap &>/dev/null && snap list "$package" 2>/dev/null | grep -q "^$package"; then
                return 0
            fi
            return 1
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

# Install from snap (Ubuntu/Debian)
snap_install() {
    local packages=("$@")
    local installed_count=0
    local failed_count=0

    if ! command -v snap &>/dev/null; then
        log_warn "Snap not available on this system"
        for pkg in "${packages[@]}"; do
            log_installation "$pkg" "failed-no-snap"
        done
        return 1
    fi

    log_info "Installing snap packages: ${packages[*]}"

    for pkg in "${packages[@]}"; do
        # Check if already installed
        if snap list "$pkg" 2>/dev/null | grep -q "^$pkg"; then
            log_skip "Snap package already installed: $pkg"
            log_installation "$pkg" "skipped"
            continue
        fi

        log_info "Installing $pkg via snap"
        if sudo snap install "$pkg" 2>/dev/null; then
            log_success "Installed $pkg via snap"
            log_installation "$pkg" "installed-snap"
            ((installed_count++))
        else
            log_error "Failed to install $pkg via snap"
            log_installation "$pkg" "failed-snap"
            ((failed_count++))
        fi
    done

    log_info "Snap installation summary: ${installed_count} installed, ${failed_count} failed"

    # Return success if at least one package was installed
    [ $installed_count -gt 0 ] && return 0 || return 1
}

# Install from AUR (Arch-based only) - non-blocking
aur_install() {
    if [ "$PKG_MANAGER" != "pacman" ]; then
        log_warn "AUR not available on $DISTRO, skipping AUR packages"
        return 0
    fi

    if [ "$AUR_HELPER" = "none" ]; then
        if ! install_aur_helper; then
            log_error "Failed to install AUR helper"
            return 1
        fi
    fi

    local packages=("$@")
    local to_install=()
    local installed_count=0
    local failed_count=0
    local skipped_count=0

    # Filter already installed AUR packages
    for pkg in "${packages[@]}"; do
        if ! pkg_is_installed "$pkg"; then
            to_install+=("$pkg")
        else
            log_skip "AUR package already installed: $pkg"
            log_installation "$pkg" "skipped"
            ((skipped_count++))
        fi
    done

    # Nothing to install
    if [ ${#to_install[@]} -eq 0 ]; then
        log_info "All AUR packages already installed"
        return 0
    fi

    log_info "Installing AUR packages: ${to_install[*]}"

    # Install packages one by one to allow continuation on failure
    for pkg in "${to_install[@]}"; do
        log_info "Installing $pkg from AUR"
        local install_success=false

        case "$AUR_HELPER" in
            yay)
                if yay -S --noconfirm "$pkg" 2>/dev/null; then
                    install_success=true
                fi
                ;;
            paru)
                if paru -S --noconfirm "$pkg" 2>/dev/null; then
                    install_success=true
                fi
                ;;
            pamac)
                if pamac install --no-confirm "$pkg" 2>/dev/null; then
                    install_success=true
                fi
                ;;
            *)
                log_error "No AUR helper available"
                log_installation "$pkg" "failed-no-aur-helper"
                ((failed_count++))
                continue
                ;;
        esac

        if [ "$install_success" = true ] && pkg_is_installed "$pkg"; then
            log_success "Installed $pkg from AUR"
            log_installation "$pkg" "installed-aur"
            ((installed_count++))
        else
            log_error "Failed to install $pkg from AUR"
            log_installation "$pkg" "failed-aur"
            ((failed_count++))
            log_warn "Continuing despite AUR installation failure for $pkg"
        fi
    done

    log_info "AUR installation summary: ${installed_count} installed, ${failed_count} failed, ${skipped_count} skipped"

    # Return success if at least one package was installed or all were skipped
    if [ $installed_count -gt 0 ] || [ $failed_count -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Remove package (if needed)
pkg_remove() {
    local package="$1"

    log_info "Removing package: $package"

    case "$PKG_MANAGER" in
        apt)
            sudo apt remove -y "$package"
            ;;
        pacman)
            sudo pacman -Rns --noconfirm "$package"
            ;;
        dnf)
            sudo dnf remove -y "$package"
            ;;
        zypper)
            sudo zypper remove -y "$package"
            ;;
        *)
            log_error "Unknown package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
}

pkg_remove_if_installed() {
    local package="$1"
    if pkg_is_installed "$package"; then
        pkg_remove "$package"
    else
        log_info "Package $package is not installed, skipping removal."
    fi
}

