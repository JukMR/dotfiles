#!/usr/bin/env bash
set -euo pipefail

readonly REPO="jesseduffield/lazygit"
readonly INSTALL_DIR="/usr/local/bin"
readonly ARCHIVE_NAME="lazygit.tar.gz"

log() {
    printf "[INFO] %s\n" "$1"
}

error() {
    printf "[ERROR] %s\n" "$1" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || error "Missing required command: $1"
}

detect_os() {
    [[ -f /etc/os-release ]] || error "/etc/os-release not found"

    # shellcheck disable=SC1091
    source /etc/os-release

    echo "$ID"
}

check_ubuntu_version() {
    local version_major
    version_major="$(echo "$VERSION_ID" | cut -d. -f1)"

    if [[ "$version_major" -lt 24 ]]; then
        error "Ubuntu 24.04+ required. Current: $PRETTY_NAME"
    fi
}

install_with_pacman() {
    log "Installing lazygit via pacman"
    sudo pacman -S --noconfirm --needed lazygit
}

install_from_github() {
    require_cmd curl
    require_cmd tar
    require_cmd sudo

    log "Fetching latest lazygit release version"
    local version
    version="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
        | grep -Po '"tag_name": *"v\K[^"]*')"

    [[ -n "$version" ]] || error "Failed to fetch latest version"

    log "Downloading lazygit v${version}"
    curl -fsSL -o "$ARCHIVE_NAME" \
        "https://github.com/${REPO}/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"

    tar xf "$ARCHIVE_NAME" lazygit
    sudo install lazygit -D -t "$INSTALL_DIR"

    rm -f lazygit "$ARCHIVE_NAME"

    log "Installed lazygit v${version} to ${INSTALL_DIR}"
}

main() {
    local os
    os="$(detect_os)"

    case "$os" in
        ubuntu)
            check_ubuntu_version
            install_from_github
            ;;
        arch|manjaro)
            install_with_pacman
            ;;
        *)
            error "Unsupported distribution: $os"
            ;;
    esac
}

main "$@"

