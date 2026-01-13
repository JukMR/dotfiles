#!/bin/bash
# programs/example/install.sh - Example program installation script
# This template shows how to make program-specific install scripts distribution-agnostic

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTDIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source library functions if available
if [ -f "$DOTDIR/lib/detect.sh" ]; then
    source "$DOTDIR/lib/detect.sh"
    source "$DOTDIR/lib/logging.sh"
    source "$DOTDIR/lib/package_manager.sh"
else
    # Fallback if libraries not available
    log_info() { echo "[INFO] $*"; }
    log_error() { echo "[ERROR] $*" >&2; }
    log_success() { echo "[SUCCESS] $*"; }
    log_skip() { echo "[SKIP] $*"; }
fi

PROGRAM_NAME="example-program"
PROGRAM_COMMAND="example"

# Check if program is already installed
if command -v "$PROGRAM_COMMAND" &>/dev/null; then
    VERSION=$("$PROGRAM_COMMAND" --version 2>/dev/null | head -n1)
    log_skip "$PROGRAM_NAME is already installed: $VERSION"
    exit 0
fi

log_info "Installing $PROGRAM_NAME"

# Method 1: Install via package manager (preferred)
install_via_package_manager() {
    local pkg_name="$1"

    case "${PKG_MANAGER:-unknown}" in
        apt)
            sudo apt update
            sudo apt install -y "$pkg_name"
            ;;
        pacman)
            sudo pacman -S --noconfirm --needed "$pkg_name"
            ;;
        dnf)
            sudo dnf install -y "$pkg_name"
            ;;
        *)
            return 1
            ;;
    esac
}

# Method 2: Install from official script/binary
install_from_source() {
    log_info "Installing $PROGRAM_NAME from source"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1

    # Example: download and install
    # curl -LO https://example.com/program
    # chmod +x program
    # sudo mv program /usr/local/bin/

    cd - >/dev/null || true
    rm -rf "$tmp_dir"
}

# Method 3: Install via language package manager (pip, npm, cargo, etc.)
install_via_language_pm() {
    if command -v pip3 &>/dev/null; then
        pip3 install --user "$PROGRAM_NAME"
    elif command -v cargo &>/dev/null; then
        cargo install "$PROGRAM_NAME"
    else
        return 1
    fi
}

# Try installation methods in order
if install_via_package_manager "$PROGRAM_NAME"; then
    log_success "$PROGRAM_NAME installed via package manager"
elif install_from_source; then
    log_success "$PROGRAM_NAME installed from source"
elif install_via_language_pm; then
    log_success "$PROGRAM_NAME installed via language package manager"
else
    log_error "Failed to install $PROGRAM_NAME"
    exit 1
fi

# Verify installation
if command -v "$PROGRAM_COMMAND" &>/dev/null; then
    VERSION=$("$PROGRAM_COMMAND" --version 2>/dev/null | head -n1)
    log_success "$PROGRAM_NAME installed successfully: $VERSION"

    # Post-installation configuration
    log_info "Configuring $PROGRAM_NAME"

    # Example: copy configuration files
    CONFIG_DIR="$HOME/.config/$PROGRAM_NAME"
    mkdir -p "$CONFIG_DIR"

    if [ -f "$SCRIPT_DIR/config.conf" ]; then
        cp "$SCRIPT_DIR/config.conf" "$CONFIG_DIR/"
        log_success "Configuration file copied"
    fi

    exit 0
else
    log_error "$PROGRAM_NAME installation verification failed"
    exit 1
fi
