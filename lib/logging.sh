#!/bin/bash
# lib/logging.sh - Enhanced logging utilities

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Log file location
LOG_FILE="${LOG_FILE:-$HOME/dotfiles_setup.log}"
INSTALL_LOG="${INSTALL_LOG:-$HOME/dotfiles_installed.log}"

# Initialize logging
init_logging() {
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    mkdir -p "$log_dir"
    
    # Start log with timestamp
    {
        echo "=================================="
        echo "Dotfiles Setup Log"
        echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "User: $USER"
        echo "Distribution: ${DISTRO:-unknown}"
        echo "Package Manager: ${PKG_MANAGER:-unknown}"
        echo "=================================="
        echo ""
    } >> "$LOG_FILE"
}

# Log function with levels
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Console output with color
    case "$level" in
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message" >&2
            ;;
        DEBUG)
            if [ "${DEBUG_MODE:-0}" = "1" ]; then
                echo -e "${BLUE}[DEBUG]${NC} $message" >&2
            fi
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} $message" >&2
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $message" >&2
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        SKIP)
            echo -e "${YELLOW}[SKIP]${NC} $message" >&2
            ;;
        *)\
            echo "[UNKNOWN] $message" >&2
            ;;\
    esac
    
    # File output without color
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Convenience functions
log_info() {
    log INFO "$@"
}

log_debug() {
    log DEBUG "$@"
}

log_success() {
    log SUCCESS "$@"
}

log_warn() {
    log WARN "$@"
}

log_error() {
    log ERROR "$@"
}

log_error_and_exit() {
    log ERROR "$@"
    exit 1
}

log_skip() {
    log SKIP "$@"
}

# Log installation of a package
log_installation() {
    local package="$1"
    local status="$2" # installed, skipped, failed
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $package: $status" >> "$INSTALL_LOG"
}

# Check if program is already installed
is_installed() {
    local program="$1"
    if command -v "$program" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check and log if program is installed
check_and_log() {
    local program="$1"\
    local display_name="${2:-$program}"
    
    if is_installed "$program"; then
        log_skip "$display_name is already installed"
        return 0
    else
        log_info "$display_name is not installed"
        return 1
    fi
}

# Run command with logging
run_logged() {
    local description="$1"
    shift
    
    log_info "Running: $description"
    
    if "$@" >> "$LOG_FILE" 2>&1; then
        log_success "$description completed"
        return 0
    else
        log_error "$description failed"
        return 1
    fi
}

# Create summary at the end
create_summary() {
    {
        echo ""
        echo "=================================="
        echo "Setup Summary"
        echo "Completed: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=================================="
        echo ""
        echo "Installation log: $INSTALL_LOG"
    } >> "$LOG_FILE"
    
    log_success "Setup completed! Check logs at: $LOG_FILE"
}
